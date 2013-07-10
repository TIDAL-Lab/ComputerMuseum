/*
 * Computer History Museum Frog Pond
 * Copyright (c) 2013 Michael S. Horn
 * 
 *           Michael S. Horn (michael-horn@northwestern.edu)
 *           Northwestern University
 *           2120 Campus Drive
 *           Evanston, IL 60613
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License (version 2) as
 * published by the Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
part of ComputerHistory;

  
class Parameter implements Touchable {
  
  double dx, dy, width, height;
  
  double downX, downY, lastX = 0.0, lastY = 0.0;
  
  int downIndex = 0;
  
  var values = [ 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, '?' ];
  
  int _index = 0;
  
  double vspace;
  
  String color = '#777';
  
  String textColor = 'white';
  
  bool dragging = false;
  
  Block block;
  

  Parameter(this.block) {
    width = 28.0;
    height = 22.0;
    dx = 0.0;
    dy = block.height/2 + height/2 - 1;
    vspace = height * 0.85;
  }
  
  
  Parameter clone(Block parent) {
    Parameter p = new Parameter(parent);
    p.width = width;
    p.height = height;
    p.values = values;
    p.index = index;
    return p;
  }
  
  
  int get index => _index;
  
  
  void set index(int i) { _index = (max(i, 0) % values.length); }
  
  
  String compile() {
    return valueAsString;
  }
  
  
  dynamic operator[](int i) {
    return values[i % values.length];
  }
  
  
  void operator[]=(int i, var value) {
    if (i >= 0 && i < values.length) {
      values[i] = value;
    }
  }

  
  String get valueAsString {
    return value.toString();
  }
  
  
  dynamic get value {
    if (index >= 0 && index < values.length) {
      return values[index];
    } else {
      return null;
    }
  }
  
  
  double _throttleIndex(double i) {
    //i = min(max(i, -0.2), values.length - 0.8);
    i = i % values.length;
    if (i - i.floor() < 0.15) {
      i = i.floor().toDouble();
    } else if (i.ceil() - i < 0.15) {
      i = i.ceil().toDouble();
    }
    return i;
  }

  
  double _getDragIndexX() {
    return _throttleIndex(downIndex - ((lastX - downX) / vspace));
  }
  
  double _getDragIndexY() {
    return _throttleIndex(downIndex - ((lastY - downY) / vspace));
  }
  
  double _getDragIndex() {
    return dragging ? _getDragIndexY() : index.toDouble();
  }
  
  void _drawVerticalArrows(CanvasRenderingContext2D ctx) {
    double x = block.x + dx;
    double y = block.y + dy;
    double w = width;
    double h = height;
    //double dy = (downIndex - _getDragIndex()) * vspace;
    double dy = (lastY - downY);
    double y0 = y + h/2 + dy;
    double y1 = y - h/2 + dy;
    double x0 = x - w/2 + 4;
    double x1 = x + w/2 - 4;
    ctx.fillStyle = 'white';
    ctx.strokeStyle = 'white';
    ctx.beginPath();
    ctx.moveTo(x0, y0 + 2);
    ctx.lineTo(x, y0 + 15);
    ctx.lineTo(x1, y0 + 2);
    ctx.closePath();
    ctx.moveTo(x0, y1 - 2);
    ctx.lineTo(x, y1 - 15);
    ctx.lineTo(x1, y1 - 2);
    ctx.closePath();
    ctx.fill();
    ctx.beginPath();
    ctx.lineWidth = 3;
    ctx.moveTo(x, y1 - 5);
    ctx.lineTo(x, y0 + 5);
    ctx.stroke();
  }

  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.font = '200 10pt sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    num tw = ctx.measureText(valueAsString).width * 1.2;
    
    double x = block.x + dx;
    double y = block.y + dy;
    double w = max(width, tw);
    double h = height;
    
    if (dragging) _drawVerticalArrows(ctx);
    
    ctx.beginPath();
    roundRect(ctx, x - w/2, y - h/2, w, h, 6);
    //ctx.arc(x, y, w/2, 0, PI * 2, true);
    ctx.fillStyle = color;
    ctx.strokeStyle = 'white';
    ctx.lineWidth = 1;
    ctx.lineJoin = 'round';
    ctx.fill();
    ctx.stroke();
    ctx.save();
    {
      ctx.clip();
      ctx.fillStyle = textColor;
      num ty = y - _getDragIndex() * vspace;
      for (int i=-2; i<values.length + 1; i++) {
        ctx.fillText(this[i].toString(), x, ty + i * vspace);
      }
    }
    ctx.restore();
  }
  
  
  bool containsTouch(Contact c) {
    return (block.isInProgram && 
            c.touchX >= block.x + dx - width/2 &&
            c.touchY >= block.y + dy - height/2 &&
            c.touchX <= block.x + dx + width/2 &&
            c.touchY <= block.y + dy + height/2);
  }
  
  
  void touchUp(Contact c) {
    index = _getDragIndex().round().toInt();
    downIndex = index;
    dragging = false;
    block.workspace.repaint();
  }
  
  
  bool touchDown(Contact c) {
    downX = c.touchX;
    downY = c.touchY;
    lastX = c.touchX;
    lastY = c.touchY;
    downIndex = index;
    dragging = true;
    block.workspace.repaint();
    return true;
  }
  
  
  void touchDrag(Contact c) {
    //int oldindex = getDragIndex().round().toInt();
    num oldIndex = _getDragIndex() % values.length;
    lastX = c.touchX;
    lastY = c.touchY;
    num newIndex = _getDragIndex() % values.length;
    if (oldIndex != newIndex && newIndex == newIndex.floor()) {
      index = _getDragIndex().round().toInt();
      block.workspace.resetPreview();
      block.workspace.preview(block);
      Sounds.playSound("tick");
    }
    block.workspace.repaint();
  }
  
  
  void touchSlide(Contact c) { }
  
}

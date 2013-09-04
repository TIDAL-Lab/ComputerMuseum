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
  
  double centerX, centerY, width, height;
  
  double downX, downY, lastX = 0.0, lastY = 0.0;
  
  int downIndex = 0;
  
  var values = [ 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, '?' ];
  
  int _index = 0;
  
  double vspace;
  
  String color = 'white'; //'#777';
  
  String textColor = 'blue'; //'white';
  
  bool dragging = false;
  
  bool changed = false;
  
  Block block;
  

  Parameter(this.block) {
    centerX = block.width - 22;
    centerY = block.height / 2;
    width = 28.0;
    height = 20.0;
    vspace = height * 0.85;
    textColor = block.color;
  }
  
  
  Parameter clone(Block parent) {
    Parameter p = new Parameter(parent);
    p.centerX = centerX;
    p.centerY = centerY;
    p.width = width;
    p.height = height;
    p.values = values;
    p.index = index;
    p.color = color;
    p.textColor = textColor;
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
    double x = centerX + block.x - 18;
    double cx = x + width / 2;
    double cy = centerY + block.y;
    double w = 19.0;
    double h = height;
    //double dy = (downIndex - _getDragIndex()) * vspace;
    double dy = (lastY - downY);
    double y0 = cy + h/2 + dy;
    double y1 = cy - h/2 + dy;
    double x0 = cx - w/2 + 4;
    double x1 = cx + w/2 - 4;
    ctx.fillStyle = 'white';
    ctx.strokeStyle = 'white';
    ctx.beginPath();
    ctx.moveTo(x0, y0 + 2);
    ctx.lineTo(cx, y0 + 15);
    ctx.lineTo(x1, y0 + 2);
    ctx.closePath();
    ctx.moveTo(x0, y1 - 2);
    ctx.lineTo(cx, y1 - 15);
    ctx.lineTo(x1, y1 - 2);
    ctx.closePath();
    ctx.fill();
    ctx.beginPath();
    ctx.lineWidth = 3;
    ctx.moveTo(cx, y1 - 5);
    ctx.lineTo(cx, y0 + 5);
    ctx.stroke();
  }
  
  
  num getDisplayWidth(CanvasRenderingContext2D ctx) {
    num w = 14;
    ctx.save();
    {
      ctx.font = '400 10pt sans-serif';
      w += ctx.measureText(valueAsString).width;      
    }
    ctx.restore();
    return w;
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    
    ctx.font = '400 10pt sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    width = ctx.measureText(valueAsString).width + 14;

    double x = centerX + block.x - 18;
    double y = centerY + block.y;
    double w = width;
    double h = height;
    
    if (dragging) _drawVerticalArrows(ctx);
    
    ctx.beginPath();
    roundRect(ctx, x, y - h/2, w, h, h/2);
    ctx.fillStyle = color;
    ctx.strokeStyle = textColor;
    ctx.lineWidth = 1;
    ctx.fill();
    ctx.stroke();
    ctx.save();
    {
      ctx.clip();
      ctx.fillStyle = textColor;
      num ty = y - _getDragIndex() * vspace;
      for (int i=-2; i<values.length + 1; i++) {
        ctx.fillText(this[i].toString(), x + w/2, ty + i * vspace);
      }
    }
    ctx.restore();
  }
  
  
  bool containsTouch(Contact c) {
    double cx = centerX + block.x - 18 + width/2;
    double cy = centerY + block.y;
    return (block.isInProgram && 
            c.touchX >= cx - width/2 &&
            c.touchY >= block.y &&
            c.touchX <= block.x + block.width &&
            c.touchY <= block.y + block.height);
  }
  
  
  void touchUp(Contact c) {
    index = _getDragIndex().round().toInt();
    if (index != downIndex) changed = true;
    downIndex = index;
    dragging = false;
    block.workspace.draw();
  }
  
  
  bool touchDown(Contact c) {
    downX = c.touchX;
    downY = c.touchY;
    lastX = c.touchX;
    lastY = c.touchY;
    downIndex = index;
    dragging = true;
    block.workspace.draw();
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
      block.parameterChanged(this);
      Sounds.playSound("click");
    }
    block.workspace.draw();
  }
  
  
  void touchSlide(Contact c) { }
}

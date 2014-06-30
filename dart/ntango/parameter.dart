/*
 * Frog Pond Evolution
 * Copyright (c) 2014 Michael S. Horn
 * 
 *           Michael S. Horn (michael-horn@northwestern.edu)
 *           Northwestern University
 *           2120 Campus Drive
 *           Evanston, IL 60613
 *           http://tidal.northwestern.edu
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation.
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
part of NetTango;


  
class Parameter implements Touchable {
  
  double centerX, centerY, width, height;
  
  double lastX = 0.0, lastY = 0.0;
  
  // location of callout menu
  num menuX;
  
  int downIndex = 0;
  
  var values = [ 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, '?' ];
  
  int _index = 0;
  
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
  
  
  num getDisplayWidth(CanvasRenderingContext2D ctx) {
    num w = 20;
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
    
    ctx.beginPath();
    roundRect(ctx, x, y - h/2, w, h, h/2);
    ctx.fillStyle = color;
    ctx.strokeStyle = textColor;
    ctx.lineWidth = 1;
    ctx.fill();
    ctx.stroke();
    ctx.fillStyle = textColor;
    ctx.fillText(valueAsString, x + w/2, y);
    
    if (dragging) {
      drawMenu(ctx);
    }
  }
  
  
  void drawMenu(CanvasRenderingContext2D ctx) {
    ctx.font = '400 14pt sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';
    
    num margin = 20;
    num mx = menuX;
    num mw = 120; //margin * 2;
    num mh = values.length * 40 + margin;
    num my = block.y + block.height + 35 - mh;
    for (int i=0; i<values.length; i++) {
      mw = max(mw, ctx.measureText(values[i].toString()).width + margin * 2);
    }
    
    ctx.fillStyle = '#3399aa';
    ctx.strokeStyle = 'white';
    calloutRect(ctx, mx, my, mw, mh, 10, block.y + centerY);
    ctx.fill();
    ctx.stroke();
    
    ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
    ctx.strokeStyle = 'rgba(0, 30, 50, 0.4)';
    mx += 5;
    my += 5;
    mw -= 10;
    mh -= 10;
    roundRect(ctx, mx, my, mw, mh, 8);
    ctx.fill();
    ctx.stroke();
    
    ctx.fillStyle = '#3399aa';
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.2)';
    
    bool matched = false;
    
    for (int i=0; i<values.length; i++) {
      num ty = my + 5 + 40 * i;
      if (i == downIndex) {
        ctx.fillStyle = 'rgba(51, 150, 170, 0.7)';
        ctx.fillRect(mx, ty, mw, 40);
        ctx.fillStyle = 'rgba(255, 255, 255, 0.85)';
      } else {
        ctx.fillStyle = '#3399aa';
      }
      
      if (lastX >= mx && lastX <= mx + mw &&
          lastY >= ty && lastY < ty + 40) {
        ctx.fillStyle = 'rgba(170, 20, 0, 0.8)';
        ctx.fillRect(mx, ty, mw, 40);
        ctx.fillStyle = 'rgba(255, 255, 255, 0.85)';
        index = i;
        matched = true;
      } 
      ctx.fillText(values[i].toString(), mx + 15, ty + 8);
    }
    if (!matched) index = downIndex;
  }
  
  
  void calloutRect(CanvasRenderingContext2D ctx, num x, num y, num w, num h, num r, num cy) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    
    ctx.lineTo(x, cy + 15);
    ctx.lineTo(x - 25, cy);
    ctx.lineTo(x, cy - 15);
    
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();
  }

  
  bool containsTouch(Contact c) {
    return (block.isInProgram && 
            c.touchX >= centerX + block.x - 18 &&
            c.touchY >= block.y &&
            c.touchX <= block.x + block.width &&
            c.touchY <= block.y + block.height);
  }
  
  
  void touchUp(Contact c) {
    if (index != downIndex) changed = true;
    downIndex = index;
    dragging = false;
    block.workspace.draw();
  }
  
  
  bool touchDown(Contact c) {
    lastX = c.touchX;
    lastY = c.touchY;
    // fix location of the callout menu
    menuX = block.x + block.width + 30; 
    downIndex = index;
    dragging = true;
    block.workspace.moveToTop(block);
    block.workspace.draw();
    return true;
  }
  
  
  void touchDrag(Contact c) {
    lastX = c.touchX;
    lastY = c.touchY;
    block.workspace.draw();
  }
  
  
  void touchSlide(Contact c) { }
}

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

/**
 * Visual indicator for program execution
 */
class TraceBug {

  double x = 0.0, y = 0.0;
  
  Block target = null;
  
  StartBlock start;
  
  
  TraceBug(this.start) {
    target = start;
    x = targetX;
    y = targetY;
  }
  
  
  num get targetX => (target == null) ? 0.0 : (target.x + target.width + 6);
  
  num get targetY => (target == null) ? 0.0 : (target.y + target.height / 2);
  
  
  bool animate() {
    if (target == null) return false;
    
    double dx = targetX - x;
    double dy = targetY - y;
    if (dx.abs() > 1) dx *= 0.3;
    if (dy.abs() > 1) dy *= 0.3;
    
    if (dx.abs() > 0 || dy.abs() > 0) {
      x += dx;
      y += dy;
      return true;
    } else {
      return false;
    }
  }
  
  
  void reset() {
    target = start;
    x = targetX;
    y = targetY;
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    if (target == null || target is StartBlock) return;
    
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x + 9, y - 7);
    ctx.lineTo(x + 8, y - 3);
    ctx.lineTo(x + 20, y - 3);
    ctx.lineTo(x + 20, y + 3);
    ctx.lineTo(x + 8, y + 3);
    ctx.lineTo(x + 9, y + 7);
    ctx.closePath();
    ctx.fillStyle = "yellow"; //"#900";
    ctx.strokeStyle = "yellow";
    ctx.lineWidth = 2;
    ctx.fill();
    ctx.stroke();
  }
}
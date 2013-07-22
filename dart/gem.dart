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


class Gem extends Turtle {
  
  
  var colors = [ 'red', 'green', 'orange', 'blue' ];
  
  int width = 0, height = 0;
  double deltaX, deltaY;
  
  
  Gem() : super() {
    heading = 0.0;
    int color = Turtle.rand.nextInt(colors.length);
    img.src = "images/gems/${colors[color]}.png";
    img.onLoad.listen((e) {
      width = img.width;
      height = img.height;
    });
  }
  
  
  bool animate() {
    if (tween.isTweening()) {
      tween.animate();
      return true;
    } else {
      return false;
    }
  }
  
  
  void flyTo(num tx, num ty) {
    deltaX = (tx.toDouble() - x);
    deltaY = (ty.toDouble() - y);
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 18;
    tween.onstart = (() { Sounds.playSound("chimes"); });
    tween.onend = (() { });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(1, 1);
    tween.ondelta = ((value) {
      x += value * deltaX;
      y += value * deltaY;
      left(360 * 4 * value);
      size -= value * 0.5;
    });
  }
  
  
  bool overlaps(double tx, double ty, double dw) {
    num dist = distance(tx, ty, x, y);
    return dist < (width/2 + dw/2);
  }
  
  
  void _drawLocal(CanvasRenderingContext2D ctx) {
    double iw = width * size;
    double ih = height * size;
    ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
  }
}

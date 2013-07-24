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
  
  
  static var colors = [ 'red', 'orange', 'blue', 'green' ];
  
  int _width = 0, _height = 0;
  
  String color;
  
  double deltaX, deltaY;
  
  ImageElement shadow = new ImageElement();
  
  bool shadowed = false;
  
  
  Gem() : super() {
    int r = Turtle.rand.nextInt(Gem.colors.length);
    _init(Gem.colors[r]);
  }
  
  
  Gem.fromColor(String clr) {
    _init(clr);
  }
  
  
  void _init(String color) {
    this.color = color;
    heading = 0.0;
    img.src = "images/gems/${color}.png";
    img.onLoad.listen((e) {
      _width = img.width;
      _height = img.height;
    });
    shadow.src = "images/gems/${color}_shadow.png";
  }
  
  
  num get width => _width * size;
  
  num get height => _height * size;
  
  
  bool animate() {
    if (tween.isTweening()) {
      tween.animate();
      return true;
    } else {
      return false;
    }
  }
  
  
  void flyTo(num tx, num ty, Function onDone) {
    deltaX = (tx.toDouble() - x);
    deltaY = (ty.toDouble() - y);
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 18;
    tween.onstart = (() { Sounds.playSound("chimes"); });
    tween.onend = (() { die(); onDone(); });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(1, 1);
    tween.ondelta = ((value) {
      x += value * deltaX;
      y += value * deltaY;
      left(360 * 4 * value);
      size -= value * 0.25;
    });
  }
  
  
  bool overlaps(double tx, double ty, double dw) {
    num dist = distance(tx, ty, x, y);
    return dist < (width/2 + dw/2);
  }
  
  
  void _drawLocal(CanvasRenderingContext2D ctx) {
    if (shadowed) {
      ctx.drawImageScaled(shadow, -width/2, -height/2, width, height);
    } else {
      ctx.drawImageScaled(img, -width/2, -height/2, width, height);
    }
  }
}

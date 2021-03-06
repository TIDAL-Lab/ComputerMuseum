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


class Fly extends Turtle {
  
  double _turn = 3.0;
  
  int perch = 0;
  
  FrogPond pond;
  
  
  Fly(this.pond) : super() {
    img.src = "images/dragonfly.png";
    this.x = Turtle.rand.nextInt(pond.width).toDouble();
    this.y = Turtle.rand.nextInt(pond.height).toDouble();
  }
  
  
  Fly hatch() {
    Fly clone = new Fly(pond);
    clone.copy(this);
    return clone;
  }
  
  
  void forward(double distance) {
    super.forward(distance);
    if (x < -30) x += pond.width;
    if (y < -30) y += pond.height;
    if (x > pond.width + 30) x -= pond.width;
    if (y > pond.height + 30) y -= pond.height;
  }
  
  
  bool animate() {
    if (perch <= 0) {
      forward(4.0);
      left(_turn);
      if (Turtle.rand.nextInt(100) > 98) {
        _turn = Turtle.rand.nextDouble() * 6.0 - 3.0;
      } else if (Turtle.rand.nextInt(1000) > 998 && !pond.inWater(x, y)) {
        perch = Turtle.rand.nextInt(100);
      }
    } else {
      perch--;
    }
    return true;
  }
  
  
  void _drawLocal(CanvasRenderingContext2D ctx) {
    if (dead) return;
    num iw = img.width * 0.7;
    num ih = img.height * 0.7;
    ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
  }
}

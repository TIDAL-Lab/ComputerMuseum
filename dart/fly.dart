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
  
  double radius = 3.0;
  
  int perch = 0;
  
  FrogPond pond;
  
  
  Fly(this.pond, double x, double y) : super() {
    img.src = "images/dragonfly.png";
    this.x = x;
    this.y = y;
  }
  
  
  void forward(double distance) {
    super.forward(distance);
    if (x < 0) x += pond.width;
    if (y < 0) y += pond.height;
    if (x > pond.width) x -= pond.width;
    if (y > pond.height) y -= pond.height;
  }
  
  
  bool animate() {
    if (perch <= 0) {
      forward(4.0);
      left(radius);
      if (Turtle.rand.nextInt(100) > 98) {
        radius = Turtle.rand.nextDouble() * 6.0 - 3.0;
      } else if (Turtle.rand.nextInt(1000) > 995 && !pond.inWater(x, y)) {
        perch = Turtle.rand.nextInt(400);
      }
    } else {
      perch--;
    }
    return true;
  }
  
  
  void _drawLocal(CanvasRenderingContext2D ctx) {
    num iw = img.width * 0.7;
    num ih = img.height * 0.7;
    ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
  }
}

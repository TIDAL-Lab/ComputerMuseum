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
  
  
  Fly() : super() {
    img.src = "images/dragonfly.png";
  }
  
  
  bool animate() {
    forward(0.1);
    left(radius);
    if (Turtle.rand.nextInt(100) > 98) {
      radius = Turtle.rand.nextDouble() * 6.0 - 3.0;
    }
    return true;
  }
  
  
  void _drawLocal(CanvasRenderingContext2D ctx) {
    num iw = img.width / 70;
    num ih = img.height / 70;
    ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
  }
}

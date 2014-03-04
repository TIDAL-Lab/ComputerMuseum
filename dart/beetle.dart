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


class Beetle extends Fly {
  
  double _turn = 1.5;
  
  int frame = 1;
  
  bool perched = false;
  
  bool locked = false;
  
  bool shadowed = false;
  
  ImageElement frame0 = new ImageElement();
  ImageElement frame1 = new ImageElement();
  ImageElement frame2 = new ImageElement();
  ImageElement shadow = new ImageElement();

  static var colors = [ 'red', 'green', 'blue', 'yellow' ];
  
  String color;
  
  Beetle(FrogPond pond, [ String color = null ]) : super(pond) {
    if (color == null) {
      color = Beetle.colors[Turtle.rand.nextInt(colors.length)];      
    }
    this.color = color;    
    img.src = "images/gems/beetle_${color}2.png";
    frame0.src = "images/gems/beetle_${color}0.png";
    frame1.src = "images/gems/beetle_${color}1.png";
    frame2.src = "images/gems/beetle_${color}2.png";
    shadow.src = "images/gems/beetle_shadow.png";
  }
  
  
  Fly hatch() {
    Beetle clone = new Beetle(pond, color);
    clone.copy(this);
    return clone;
  }
  
  
  void spook() {
    perched = false;
  }
  
  
  bool animate() {
    frame++;
    if (frame > 1) frame = 0;
    
    if (tween.isTweening()) {
      tween.animate();
      return true;
    }
    else if (perched) {
      if (locked) {
        return false;
      }
      else if (Turtle.rand.nextInt(100) > 98) {
        left(15.0);
        return true;
      } else if (Turtle.rand.nextInt(100) > 98) {
        right(15.0);
        return true;
      } else {
        return false;
      }
    } else {
      forward(6.0);
      left(_turn);
      if (pond.onGridPoint(x, y, 8) &&
          !pond.isFrogHere(this) &&
          pond.bugs.getTurtlesHere(this).isEmpty) {
        perched = true;
      }
      else if (Turtle.rand.nextInt(100) > 98) {
        _turn = Turtle.rand.nextDouble() * 3.0 - 1.5;
      } 
      return true;
    } 
  }
  
  
  void _drawLocal(CanvasRenderingContext2D ctx) {
    if (dead) return;
    ImageElement i = (frame == 0)? frame1 : frame2;
    if (perched) i = frame0;
    if (shadowed) i = shadow;
    num iw = i.width;
    num ih = i.height;
    ctx.drawImageScaled(i, -iw/2, -ih/2, iw, ih);
  }
}

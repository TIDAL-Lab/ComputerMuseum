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


abstract class Turtle {

  /* coordinates in world space */
  double x = 0.0, y = 0.0;
  
  /* size */
  double size = 1.0;
  
  /* heading in radians */
  double heading = 0.0;
  
  /* bitmap image */
  ImageElement img = new ImageElement();
  
  /* random number generator */
  static Random rand = new Random();

  
  Turtle() {
    right(Turtle.rand.nextInt(365).toDouble());
  }
  
  
/**
 * Copy the state of the other turtle
 */
  void copy(Turtle other) {
    x = other.x;
    y = other.y;
    size = other.size;
    heading = other.heading;
    img.src = other.img.src;
  }

  
  void forward(double distance) {
    x += sin(heading) * distance;
    y -= cos(heading) * distance;
  }
  
     
  void backward(double distance) {
    forward(-distance);
  }
  
  
  void left(double degrees) {
    heading -= (degrees / 180.0) * PI;   
  }
  
  
  void right(double degrees) {
    left(-degrees);
  }
  
  
  bool animate();
    
  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save();
    {
      ctx.translate(x, y);
      ctx.rotate(heading);
      _drawLocal(ctx);
    }    
    ctx.restore();
  }
  
  
  void _drawLocal(CanvasRenderingContext2D ctx);
}
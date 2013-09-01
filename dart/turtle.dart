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
  
  /* visual alpha (opacity) of the turtle */
  double opacity = 1.0;
  
  /* turtle is marked for removal from the model */
  bool dead = false;
  
  /* used for animation effects */
  Tween tween = new Tween();
  
  /* bitmap image */
  ImageElement img = new ImageElement();
  
  /* random number generator */
  static Random rand = new Random();
  
  /* turtles-own variable storage */
  Map<String, dynamic> variables = new Map<String, dynamic>();

  /* width and height of the bitmap */
  double _width = 0.0, _height = 0.0;
  
  
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
    opacity = other.opacity;
    img.src = other.img.src;
    for (String key in other.variables.keys) {
      variables[key] = other[key];
    }
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
  
  
  void die() {
    dead = true;
  }
  
  
  bool animate();

  
  bool overlapsPoint(num tx, num ty, [ num tw = 0.0 ]) {
    if (tw <= 0) {
      return (tx > x - width/2 && ty > y - height/2 && tx < x + width/2 && ty < y + height/2);
    } else {
      num dist = distance(tx, ty, x, y);
      return dist < (width/2 + tw/2);
    }
  }
  
  
  bool overlapsTurtle(Turtle other) {
    num dist = distance(other.x, other.y, x, y);
    return dist < (radius + other.radius);
  }

  
  double get width => img.width * size;

  
  double get height => img.height * size;
  
  
  double get radius => (width < height) ? width / 2 : height / 2;
  
  
  double angleBetween(Turtle b) {
    double theta = -atan2(x - b.x, y - b.y) / PI * 180.0;
    if (theta < 0) theta += 360.0;
    double alpha = (heading / PI * 180.0) % 360;
    return alpha - theta;
  }
  
  
  dynamic operator[] (String key) {
    return variables[key];
  }
  
  
  void operator[]=(String key, var value) {
    variables[key] = value;
  }
  
  
  bool hasVariable(String name) {
    return variables.containsKey(name);
  }
  
  
  void removeVariable(String name) {
    variables.remove(name);
  }
  
  
  void clearVariables() {
    variables.clear();
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save();
    {
      if (opacity < 1.0) ctx.globalAlpha = opacity;
      ctx.translate(x, y);
      ctx.rotate(heading);
      _drawLocal(ctx);
      ctx.globalAlpha = 1.0;
    }    
    ctx.restore();
  }
  
  
  void erase(CanvasRenderingContext2D ctx) {
    ctx.clearRect(x - width/2, y - height/2, width, height);
  }


  void _drawLocal(CanvasRenderingContext2D ctx);  

}
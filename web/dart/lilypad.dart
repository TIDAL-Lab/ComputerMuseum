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


class LilyPad extends Turtle implements Touchable {
  
  /* pond that contains this lilypad */
  FrogPond pond;

  double _lastX, _lastY;
  
  bool refresh = false;

  
  LilyPad(this.pond) : super() {
    img.src = "images/lilypad.png";
  }
  
  
  bool animate() {
    return refresh;
  }

  
  void _drawLocal(CanvasRenderingContext2D ctx) {  
    /*
    ctx.beginPath();
    ctx.strokeStyle = "white";
    ctx.arc(0, 0, iw/2, 0, PI * 2, true);
    ctx.stroke();
    */
    //num iw = width;
    //num ih = height;
    //ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
  }
  
  
  bool containsTouch(Contact c) {
    num dist = distance(c.touchX, c.touchY, x, y);
    return dist < radius;
  }

  
  bool touchDown(Contact c) {
    _lastX = c.touchX;
    _lastY = c.touchY;
    return DRAG_LILYPADS;
  }

  
  void touchUp(Contact c) { }
  void touchCancel(Contact c) { }

  
  void touchDrag(Contact c) {
    move(c.touchX - _lastX, c.touchY - _lastY);
    _lastX = c.touchX;
    _lastY = c.touchY;
    refresh = true;
  }
  
  void touchSlide(Contact c) { }
}
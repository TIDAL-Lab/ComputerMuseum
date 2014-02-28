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


class Help implements Touchable {
  
  /* Owner */
  CodeWorkspace workspace;
  
  /* tween for showing / hiding the help message */
  Tween tween = new Tween();
  
  /* vertical location of the help message */
  num y;
  
  ImageElement help = new ImageElement();


  Help(this.workspace) {  
    help.src = "images/help/help2.png";
    y = workspace.height;
  }

  
  bool get isVisible => y <= workspace.height - 304;
  bool get isHidden => y >= workspace.height;


  bool animate() {
    if (tween.isTweening()) {
      tween.animate();
      return true;
    } else {
      return false;
    }
  }

  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.drawImage(help, 0, y);
  }
  
  
  void showHide() {
    if (isVisible) {
      hide();
    } else if (isHidden) {
      show();
    }
  }
  
  
  void hide() {
    if (isVisible) {
      workspace.removeTouchable(this);
      tween = new Tween();
      tween.function = TWEEN_SINE2;
      tween.delay = 0;
      tween.duration = 10;
      tween.addControlPoint(304, 0);
      tween.addControlPoint(0, 1.0);
      tween.ontick = ((value) => y = workspace.height - value );
    }
  }
  
  
  void show() {
    if (isHidden) {
      workspace.addTouchable(this);
      tween = new Tween();
      tween.function = TWEEN_SINE2;
      tween.delay = 0;
      tween.duration = 10;
      tween.addControlPoint(0, 0);
      tween.addControlPoint(304, 1.0);
      tween.ontick = ((value) => y = workspace.height - value );
    }
  }
  
  
  bool containsTouch(Contact c) {
    return (isVisible && c.touchY > workspace.height - 600);
  }
  
  
  bool touchDown(Contact c) {
    hide();
    return true;
  }
  
  
  void touchUp(Contact c) {}
  void touchDrag(Contact c) { }
  void touchSlide(Contact c) { }
  
}  

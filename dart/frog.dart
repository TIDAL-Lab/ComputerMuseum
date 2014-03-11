/*
 * Computer History Museum Frog Pond
 * Copyright (c) 2014 Michael S. Horn
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


class Frog extends Turtle implements Touchable {
  
  /* pond that contains this frog */
  FrogPond pond;
  
  /* the workspace that controls this frog */
  CodeWorkspace workspace;

  /* size of the sound wave emanating from the frog */
  double _sound = -1.0;
  
  /* length of the tongue coming out of the frog */
  double _tongue = 0.0;
  
  /* name of the command being executed */
  String label = null;
  
  /* this frog's control program */
  Program program;
  
  /* beetle captured by frog for eating */
  Beetle prey = null;
  
  
  Frog(this.pond, this.workspace) : super() {
    img.src = "images/bluefrog.png";
  }
  
  
  Frog hatch() {
    if (workspace.frogs.length < MAX_FROGS) {
      Frog clone = new Frog(pond, workspace);
      clone.copy(this);
      clone.program = new Program.copy(program, clone);
      workspace.frogs.add(clone);
      return clone;
    } else {
      return null;
    }
  }
  
  
  double get tongueX => x + sin(heading) * _tongue * height * 1.8;
  
  double get tongueY => y - cos(heading) * _tongue * height * 1.8;
  
  double get radius => super.radius * 0.75;
  
  
  void reset() {
    opacity = 1.0;
    _sound = -1.0;
    _tongue = 0.0;
    label = null;
  }
  
  
  bool animate() {
    bool refresh = false;
    if (tween.isTweening()) {
      tween.animate();
      refresh = true;
    }
    if (program.animate()) refresh = true;
    return refresh;
  }
  
  
  bool pathBlocked() {
    forward(radius * 4.0);
    bool blocked = pond.isFrogHere(this);
    backward(radius * 4.0);
    return blocked;
  }
  
  
  bool nearWater() {
    bool wet = false;
    forward(radius * 4.0);
    if (inWater()) wet = true;
    backward(radius * 4.0);
    return wet;
  }
  
  
  bool inWater() {
    return pond.inWater(x, y);
  }
  
  
  bool seeBug() {
    forward(radius * 4.0);
    Beetle bug = pond.bugs.getTurtleHere(this);
    bool b = bug != null;
    backward(radius * 4.0);
    return b;
  }
  
  
  bool isBlocked() {
    forward(radius * 4.0);
    bool blocked = pond.isFrogHere(this);
    backward(radius * 4.0);
    return blocked;
  }
  
  
  void spookBugs() {
    Set<Beetle> bugs = pond.bugs.getTurtlesHere(this);
    for (Beetle bug in bugs) {
      bug.spook();
    }
  }
  
  
  void eatBug() {
    if (prey == null) {
      Beetle bug = pond.bugs.getTurtleAtPoint(tongueX, tongueY);
      if (bug != null && !bug.dead) {
        prey = bug.hatch();
        bug.die();
      }
    } else {
      prey.x = tongueX;
      prey.y = tongueY;
    }
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    if (prey != null) prey.draw(ctx);
    super.draw(ctx);
  }
  
  
  void _drawLocal(CanvasRenderingContext2D ctx) {
    
    //---------------------------------------------
    // draw sound wave
    //---------------------------------------------
    if (_sound > 0) {
      num alpha = 1 - (_sound / 175.0);
      ctx.strokeStyle = "rgba(255, 255, 255, $alpha)";
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.arc(0, 0, _sound, 0, PI * 2, true);
      ctx.stroke();
    }
   
    //---------------------------------------------
    // draw tongue sticking out
    //---------------------------------------------
    if (_tongue > 0) {
      ctx.strokeStyle = "#922";
      ctx.lineWidth = 5;
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(0, _tongue * height * -1.6);
      ctx.stroke();
    }
    
    //---------------------------------------------
    // draw frog image
    //---------------------------------------------
    num iw = width;
    num ih = height;
    ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
  }

  
  bool containsTouch(Contact c) { return overlapsPoint(c.touchX, c.touchY); }
  void touchUp(Contact c) { }
  void touchDrag(Contact c) { }
  void touchSlide(Contact c) { }
  
  bool touchDown(Contact c) {
    workspace.frogs.moveToTop(this);
    workspace.showHideHelp();
    return true;
  }
}
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


class Frog extends Turtle implements Touchable {

  /* used for animation effects */
  Tween tween = new Tween();
  
  /* size of the sound wave emanating from the frog */
  double radius = -1.0;
  
  /* name of the command being executed */
  String label = null;
  
  /* length of the tongue coming out of the frog */
  double tongue = 0.0;

  /* saved state of this frog (for previewing) TODO: stack? */
  Frog saved = null;
  
  /* this frogs control program */
  Program program;
  
  
  Frog() : super() {
    img.src = "images/bluefrog.png";
  }
  
  
/**
 * Save the state of this frog
 */
  void save() {
    saved = hatch();
    saved.label = null;
    saved.tongue = 0.0;
    saved.radius = -1.0;
  }
  

/**
 * Restore the state of this frog
 */
  void restore() {
    if (saved != null) {
      copy(saved);
      saved = null;
    }
  }
  
  
/**
 * Copy the state of another frog
 */
  void copy(Turtle other) {
    if (other is Frog) {
      Frog frog = other as Frog;
      radius = frog.radius;
      label = frog.label;
      tongue = frog.tongue;
    }
    super.copy(other);
  }

  
  Frog hatch() {
    Frog clone = new Frog();
    clone.copy(this);
    return clone;
  }
  
  
  bool animate() {
    if (tween.isTweening()) {
      tween.animate();
      return true;
    } else if (program != null && program.isRunning) {
      program.step();
      return true;
    } else {
      return false;
    }
  }
  
  
  void _drawLocal(CanvasRenderingContext2D ctx) {
    
    //---------------------------------------------
    // draw sound wave
    //---------------------------------------------
    if (radius > 0) {
      num alpha = 1 - (radius / 150.0);
      ctx.strokeStyle = "rgba(255, 255, 255, $alpha)";
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.arc(0, 0, radius, 0, PI * 2, true);
      ctx.stroke();
    }
    
    //---------------------------------------------
    // draw command label
    //---------------------------------------------
    if (label != null) {
      ctx.save();
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.textBaseline = "top";
      ctx.textAlign = "center";
      ctx.fillStyle = "white";
      ctx.font = "16px helvetica, sans-serif";
      //ctx.fillText(label, model.worldToScreenX(x, y), model.worldToScreenY(x, y) + 65);
      ctx.fillText(label, x, y + 52);
      ctx.restore();
    }
    
    //---------------------------------------------
    // draw tongue sticking out
    //---------------------------------------------
    if (tongue > 0) {
      ctx.strokeStyle = "#922";
      ctx.lineWidth = 5;
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(0, tongue * -90.0);
      ctx.stroke();
    }
    
    //---------------------------------------------
    // draw frog image
    //---------------------------------------------
    num iw = img.width * 0.4;
    num ih = img.height * 0.4;
    
    ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
  }
  
  
  void doCommand(String cmd, Parameter param) {
    if (cmd == "hop") {
      doMove(cmd, param);
    } else if (cmd == "left") {
      doTurn(cmd, param);
    } else if (cmd == "right") {
      doTurn(cmd, param);
    } else if (cmd == "chirp") {
      doSound(cmd);
    } else if (cmd == "rest") {
      doRest(cmd);
    } else if (cmd == "eat") {
      doEat(cmd);
    } else if (cmd == "hatch") {
      doHatch(cmd);
    } else if (cmd == "end") {
      label = null;
    }
  }
  
  
  void _pause() {
    tween = new Tween();
    tween.delay = 0;
    tween.duration = 20;
    tween.onstart = (() { });
    tween.onend = (() { radius = -1.0; });
  }
  

  void doMove(String cmd, Parameter param) {
    double length = 30.0;
    if (param.value is num) {
      length *= param.value;
    }
    String s = "$cmd ${param.value}";
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 10;
    tween.onstart = (() { label = s; });
    tween.onend = (() { _pause(); });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(length, 1);
    //tween.duration = 5;
    tween.ondelta = ((value) => forward(value));
  }


  void doSound(String cmd) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.onstart = (() { label = cmd; radius = 0.5; });
    tween.onend = (() { radius = -1.0; _pause(); });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(150, 1);
    tween.duration = 25;
    tween.delay = 0;
    tween.ondelta = ((value) => radius += value);
  }
  
  
  void doEat(String cmd) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.onstart = (() { label = cmd; tongue = 0.0; });
    tween.onend = (() { _pause(); });
    tween.addControlPoint(0.0, 0.0);
    tween.addControlPoint(1.0, 0.5);
    tween.addControlPoint(0.0, 1.0);
    tween.duration = 30;
    tween.ondelta = ((value) => tongue += value);
  }


  void doTurn(String cmd, Parameter param) {
    num angle = 30;
    if (param.value is num) {
      angle = param.value;
    } else if (param.valueAsString == 'random') {
      angle = Turtle.rand.nextInt(90).toDouble();
    }
    if (cmd == 'right') {
      angle *= -1;
    }
    String s = "$cmd ${param.valueAsString}";
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 20;
    tween.onstart = (() => label = s);
    tween.addControlPoint(0, 0);
    tween.addControlPoint(angle, 1);
    tween.ondelta = ((value) => left(value));
    tween.onend = (() { _pause(); });
  }

  
  void doRest(String cmd) {
    int duration = Turtle.rand.nextInt(50) + 30;
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = duration;
    tween.onstart = (() => label = cmd);
    tween.onend = (() { _pause(); });
  }
  

  void doHatch(String cmd) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 10;
    tween.onstart = (() => label = cmd);
    tween.onend = (() { _pause(); });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(100, 1.0);
    tween.ondelta = ((value) => y += value);
  }
  
  bool containsTouch(Contact c) { return false; }
  
  bool touchDown(Contact c) { return false; }
  
  void touchUp(Contact c) { }
  
  void touchDrag(Contact c) { }
  
  void touchSlide(Contact c) { }
  
}
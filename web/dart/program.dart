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


class FrogProgram extends Program {
  
  /* Frog that owns this program */
  Frog frog;
  
  /* Used for animating frogs */
  Tween tween = new Tween();

  
  FrogProgram(CodeWorkspace workspace, this.frog) : super(workspace);
  
/*  
  Program.copy(Program other, Frog owner) {
    frog = owner;
    start = other.start;
    curr = other.curr;
    running = other.running;
  }
*/

  bool animate() {
    if (tween.isTweening()) {
      tween.animate();
      return true;
    } else if (isRunning) {
      step();
      return true;
    } else {
      running = false;
      return false;
    }
  }
  
  
  bool getSensorValue(String sensor) {
    if (sensor == "at-water?") {
      return frog.nearWater();
    } else if (sensor == "see-bug?") {
      return frog.seeBug();
    } else if (sensor == "random?") {
      return Turtle.rand.nextBool();
    } else if (sensor == "blocked?") {
      return frog.isBlocked();
    } else {
      return false;
    }
  }

  
  void doCommand(String cmd, var param) {
    frog.reset();
    if (cmd == "hop") {
      doMove(cmd, param);
    } else if (cmd == "turn" || cmd == "left" || cmd == "right") {
      doTurn(cmd, param);
    } else if (cmd == "chirp") {
      doSound(cmd, param);
    } else if (cmd == "spin") {
      doSpin(cmd, param);
    } else if (cmd == "eat") {
      doEat(cmd, param);
    } else if (cmd == "hatch") {
      doHatch(cmd, param);
    } else if (cmd == "die") {
      doDie(cmd, param);
    } else if (cmd.startsWith("if")) {
      doIf(cmd, param);
    } else if (cmd.startsWith("repeat")) {
      doRepeat(cmd, param);
    }
  }

  
  void doPause() {
    // is the frog in the water? 
    if (frog.inWater()) {
      Sounds.playSound("splash");
      frog.die();
    } else {
      tween = new Tween();
      tween.delay = 0;
      tween.duration = 20;
      tween.onstart = (() { });
      tween.onend = (() { frog.reset(); });
    }
  }
  

/**
 * Hop forward
 */
  void doMove(String cmd, var param) {
    Frog target = frog;
    double length = 150.0; //frog.radius * 4.0;
    if (param is num) length *= param;
    bool bounce = frog.pathBlocked() && FROGS_BLOCK;
    String s = "$cmd";
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 12;
    tween.onstart = (() { Sounds.playSound(cmd); target.label = s; });
    tween.onend = (() { doPause(); });
    tween.addControlPoint(0, 0);
    if (bounce) {
      tween.addControlPoint(length * 0.5, 0.5);
      tween.addControlPoint(0, 1);
    } else {
      tween.addControlPoint(length, 1);
    }
    tween.ondelta = ((value) {
      target.forward(value);
      target.spookBugs();
    });
  }
  

/**
 * Turn the frog left or right
 */
  void doTurn(String cmd, var param) {
    num angle = 60;
    if (param is num) {
      angle = param;
    } else if (param.toString() == 'random') {
      angle = Turtle.rand.nextInt(180).toDouble() - 90.0;
    }
    if (cmd == 'right') {
      angle *= -1;
    }
    Frog target = frog;
    String s = "$cmd";
    if (param != null) s = "$cmd $param";
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 20;
    tween.onstart = (() => target.label = s);
    tween.addControlPoint(0, 0);
    tween.addControlPoint(angle, 1);
    tween.ondelta = ((value) => target.left(value));
    tween.onend = (() { doPause(); });
  }
  

/**
 * Spin randomly
 */
  void doSpin(String cmd, var param) {
    num angle = 60 * Turtle.rand.nextInt(40);
    if (Turtle.rand.nextBool()) angle *= -1;
    String s = "$cmd";
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 30;
    tween.onstart = (() => frog.label = s);
    tween.addControlPoint(0, 0);
    tween.addControlPoint(angle, 1);
    tween.ondelta = ((value) => frog.left(value));
    tween.onend = (() { doPause(); });
  }
  

/**
 * Make the frog chirp
 */
  void doSound(String cmd, var param) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.onstart = (() {
      Sounds.playSound(cmd);
      frog.label = cmd;
      frog._sound = 0.5;
    });
    tween.onend = (() {
      frog._sound = -1.0;
      doPause();
    });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(175, 1);
    tween.duration = 25;
    tween.delay = 0;
    tween.ondelta = ((value) => frog._sound += value);
  }
  
  
/**
 * Make the frog stick out its tongue
 */
  void doEat(String cmd, var param) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.onstart = (() {
      frog.label = cmd;
      frog._tongue = 0.0;
    });
    tween.addControlPoint(0.0, 0.0);
    tween.addControlPoint(1.0, 0.4);
    tween.addControlPoint(0.0, 1.0);
    tween.duration = 20;
    tween.ondelta = ((value) {
      frog._tongue += value;
      frog.eatBug();
      if (frog._tongue == 1.0) Sounds.playSound("swoosh");
    });
    tween.onend = (() {
      if (frog.prey != null) {
        Sounds.playSound("gulp");
        frog.workspace.captureBug(frog.prey);
        frog.prey = null;
      }
      doPause();
    });
  }
  

/**
 * For repeats just show the text label and pause slightly
 */
  void doRepeat(String cmd, var param) {
    tween = new Tween();
    tween.duration = 5;
    tween.onstart = (() => frog.label = "$cmd $param");
    tween.onend = (() { doPause(); });
  }
  
  
/**
 * For if statements just show the label and pause slightly
 */
  void doIf(String cmd, var param) {
    tween = new Tween();
    tween.duration = 5;
    tween.onstart = (() => frog.label = "$cmd $param");
    tween.onend = (() { doPause(); });
  }
  
  
/**
 * Kill this frog
 */
  void doDie(String cmd, var param) {
    tween = new Tween();
    tween.function = TWEEN_DECAY;
    tween.delay = 0;
    tween.duration = 8;
    tween.repeat = 3;
    tween.addControlPoint(1.0, 0);
    tween.addControlPoint(0.0, 0.5);
    tween.addControlPoint(1.0, 1.0);
    tween.ondelta = ((value) => frog.opacity += value );
    tween.onend = (() {
      frog.die();
    });
  }
  

/**
 * Hatch a new frog
 */
  void doHatch(String cmd, var param) {
    Frog baby = frog.hatch();
    if (baby == null) return;
    baby.program.pause();
    baby.size = 0.05;
    baby.heading = frog.heading;
    baby.left(60.0 + Turtle.rand.nextInt(5) * 60.0);
    tween = new Tween();
    tween.function = TWEEN_DECAY;
    tween.delay = 0;
    tween.duration = 15;
    tween.onstart = (() => frog.label = cmd);
    tween.onend = (() {
      doPause();
      baby.program.play();
    });
    tween.addControlPoint(0.05, 0);
    tween.addControlPoint(frog.size, 1.0);
    tween.ondelta = ((value) => baby.size += value);
  }
}  

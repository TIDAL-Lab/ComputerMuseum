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


class Program {
  
  /* Frog that owns this program */
  Frog frog;
  
  /* Start block for the program */
  StartBlock start;
  
  /* Currently executing statement in the program */
  Block curr;
  
  /* Is the program running? */
  bool running = false;
  
  /* variable storage */
  Map<String, dynamic> variables = new Map<String, dynamic>();
  
  /* Used for animating frogs */
  Tween tween = new Tween();

  
  Program(this.start, this.frog);
  
  
  Program.copy(Program other, Frog owner) {
    frog = owner;
    start = other.start;
    curr = other.curr;
    running = other.running;
  }
  
  
  void step() {
    if (isRunning) {
      curr.eval(this);
      curr = curr.step(this);
    }
  }
  
  
  void skip() {
    if (isRunning) {
      curr = curr.step(this);
      doPause();
    }
  }
  
  
  bool animate() {
    if (tween.isTweening()) {
      tween.animate();
      return true;
    } else if (isRunning) {
      step();
      return true;
    } else {
      return false;
    }
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
  
  
  void restart() {
    curr = start;
    running = false;
  }
  
  
  void play() {
    if (curr == null || isFinished) {
      restart();
    }
    running = true;
  }
  
  
  void pause() {
    running = false;
  }
  
  
  bool get isRunning {
    return (running && curr != null && !isFinished);
  }
  
  
  bool get isFinished {
    return (curr is EndProgramBlock);
  }
  
  
  String compile() {
    String s = "void main() {\n";
    Block b = start.next;
    int indent = 1;
    while (b != null && !(b is EndProgramBlock)) {
      s += b.compile(indent);
      if (b is BeginBlock) {
        indent++;
      } else if (b is EndBlock) {
        indent--;
      }
      b = b.next;
    }
    return s + "}\n";
  }

  
  void doCommand(String cmd, var param, [ bool preview = false ]) {
    frog.reset();
    if (cmd == "hop") {
      doMove(cmd, param, preview);
    } else if (cmd == "left" || cmd == "right") {
      doTurn(cmd, param, preview);
    } else if (cmd == "chirp") {
      doSound(cmd, param, preview);
    } else if (cmd == "eat") {
      doEat(cmd, param, preview);
    } else if (cmd == "hatch") {
      doHatch(cmd, param, preview);
    } else if (cmd == "end") {
      doPause();
    } else if (cmd.startsWith("repeat")) {
      doRepeat(cmd, param, preview);
    } else if (cmd.startsWith("wait")) {
      doWait(cmd, param, preview);
    }
  }

  
  void doPause() {
    
    // is the frog in the water? 
    if (frog.inWater()) {
      Sounds.playSound("splash");
      frog.die();
      return;
    }
    
    // did we capture a gem?
    frog.captureGem();
    
    tween = new Tween();
    tween.delay = 0;
    tween.duration = 20;
    tween.onstart = (() { });
    tween.onend = (() { frog.reset(); });
  }
  

/**
 * Hop forward
 */
  void doMove(String cmd, var param, bool preview) {
    Frog target = frog;
    if (preview) {
      target = frog.hatch();
      frog.ghost = target;
      target.opacity = 0.3;
    }
    double length = frog.radius;
    if (param is num) length *= param;

    String s = "$cmd ${param}";
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 12;
    tween.onstart = (() { Sounds.playSound(cmd); target.label = s; });
    tween.onend = (() { doPause(); });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(length, 1);
    tween.ondelta = ((value) {
      target.forward(value);
      if (!preview) target.push(value);
    });
  }
  

/**
 * Turn the frog left or right
 */
  void doTurn(String cmd, var param, bool preview) {
    num angle = 30;
    if (param is num) {
      angle = param;
    } else if (param.toString() == '?') {
      angle = Turtle.rand.nextInt(90).toDouble();
    }
    if (cmd == 'right') {
      angle *= -1;
    }
    Frog target = frog;
    if (preview) {
      target = frog.hatch();
      target.opacity = 0.5;
      frog.ghost = target;
    }
    String s = "$cmd ${param}";
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
 * Make the frog chirp
 */
  void doSound(String cmd, var param, bool preview) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.onstart = (() {
      Sounds.playSound(cmd);
      frog.label = cmd;
      frog._radius = 0.5;
    });
    tween.onend = (() {
      frog._radius = -1.0;
      doPause();
    });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(175, 1);
    tween.duration = 25;
    tween.delay = 0;
    tween.ondelta = ((value) => frog._radius += value);
  }
  
  
/**
 * Make the frog stick out its tongue
 */
  void doEat(String cmd, var param, bool preview) {
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
      if (!preview) {
        frog.eatFly();
      }
      if (frog._tongue == 1.0) Sounds.playSound("swoosh");
    });
    tween.onend = (() {
      if (frog.prey != null) {
        Sounds.playSound("gulp");
        //workspace.captureFly(prey);
        frog.prey = null;
      }
      doPause();
    });
  }
  

/**
 * For repeats just show the text label and pause slightly
 */
  void doRepeat(String cmd, var param, bool preview) {
    tween = new Tween();
    tween.delay = 0;
    tween.duration = 5;
    tween.onstart = (() => frog.label = cmd);
    tween.onend = (() { doPause(); });
  }
  

/**
 * For waits we use a tight loop
 */
  void doWait(String cmd, var param, bool preview) {
    num duration = 0;
    if (param.toString() == 'fly') {
      frog._vision = 10.0;
      if (preview) duration = 30;
    }

    tween = new Tween();
    tween.duration = duration;
    tween.onstart = (() => frog.label = cmd);
    tween.onend = (() {
      if (duration > 0 || preview) {
        frog.label = null;
        frog._vision = 0.0;
      }
    });
  }
  

/**
 * Hatch a new frog
 */
  void doHatch(String cmd, var param, bool preview) {
    Frog baby;
    if (frog.pond.getFrogCount(frog["workspace"]) < MAX_FROGS) {
       baby = frog.hatch();
    }
    if (baby == null) return;
    if (preview) {
      baby.opacity = 0.3;
      frog.ghost = baby;
    } else {
      baby.program.skip();
      frog.pond.addFrog(baby);
    }
    baby.size = 0.05;
    baby.left(Turtle.rand.nextInt(360).toDouble());
    baby.forward(35.0);
    tween = new Tween();
    tween.function = TWEEN_DECAY;
    tween.delay = 0;
    tween.duration = 15;
    tween.onstart = (() => frog.label = cmd);
    tween.onend = (() => doPause());
    tween.addControlPoint(0.05, 0);
    tween.addControlPoint(frog.size + Turtle.rand.nextDouble() * 0.2 - 0.1, 1.0);
    tween.ondelta = ((value) => baby.size += value);
  }
}  

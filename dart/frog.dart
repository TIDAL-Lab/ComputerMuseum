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
  
  /* pond that contains this frog */
  FrogPond pond;
  
  /* code workspace that controls this frog */
  CodeWorkspace workspace;

  /* size of the sound wave emanating from the frog */
  double _radius = -1.0;
  
  /* name of the command being executed */
  String label = null;
  
  /* length of the tongue coming out of the frog */
  double tongue = 0.0;
  
  /* angle extent +/- of vision cone */
  double vision = -1.0;

  /* saved state of this frog (for previewing) */
  Frog ghost = null;
  
  /* this frogs control program */
  Program program;
  
  /* Fly captured by frog for eating */
  Fly prey = null;
  
  
  Frog(this.pond, this.workspace) : super() {
    img.src = "images/bluefrog.png";
  }
  
  
  Frog hatch() {
    Frog clone = new Frog(pond, workspace);
    clone.copy(this);
    return clone;
  }
  
  
  double get radius {
    return super.radius * 0.75;
  }
  
  
  bool animate() {
    if (tween.isTweening()) {
      tween.animate();
      return true;
    } else if (program != null && program.isRunning) {
      program.step();
      return true;
    } else if (ghost != null && ghost.tween.isTweening()) {
      ghost.tween.animate();
      return true;
    } else {
      return false;
    }
  }
  
  
  void forward(double distance) {
    super.forward(distance);
    for (Frog frog in pond.getFrogsHere(this)) {
      push(frog, distance);
    }
  }
  
  
  void push(Frog other, num distance) {
    double angle = angleBetween(other);
    if (angle.abs() < 90.0) {
      angle = angle / -180.0 * PI;
      angle += heading;
      double dx = distance * sin(angle);
      double dy = distance * cos(angle);
      other.x += dx;
      other.y -= dy;
      if (pond.inWater(other.x, other.y)) {
        Sounds.playSound("splash");
        other.die();
      }
    }
  }
  
  
  bool nearWater() {
    forward(60.0);
    bool wet = pond.inWater(x, y);
    backward(60.0);
    return wet;
  }
  
  
  bool seeGem() {
    for (Gem gem in pond.gems) {
      if (angleBetween(gem).abs() < 20.0) return true;
    }
    return false;
  }
    
  
  bool nearFly() {
    for (Fly fly in pond.flies) {
      if (angleBetween(fly).abs() < 10.0) {
        num d = distance(fly.x, fly.y, x, y);
        if (d > height / 4 && d < height * 1.5) {
          return true;
        }
      }
    }
    return false;
  }
  
  
  bool hearSound() {
    return false;
  }
  
  
  double get tongueX => x + sin(heading) * tongue * height * 1.5;
  
  double get tongueY => y - cos(heading) * tongue * height * 1.5;
  
  
  void drawLabel(CanvasRenderingContext2D ctx) {
    if (label != null) {
      ctx.save();
      ctx.globalAlpha = 1.0;
      ctx.textBaseline = "top";
      ctx.textAlign = "center";
      ctx.fillStyle = "white";
      ctx.font = "200 16px sans-serif";
        ctx.fillText(label, x, y + 52);
      ctx.restore();
    }
  }
  
  
  void drawProgram(CanvasRenderingContext2D ctx) {
    if (down && program != null) {
      ctx.save();
      {
        var prog = program.compile().split('\n');
        ctx.globalAlpha = 1.0;
        ctx.textBaseline = "top";
        ctx.textAlign = "left";
        ctx.fillStyle = "white";
        ctx.font = "200 16px monospace";
        num lx = x + 80;
        num ly = y - 20 * prog.length - 40;
        ctx.strokeStyle = "black";
        drawBubble(ctx, lx - 20, ly - 20, 260, y - ly, 20);
        
        ctx.fillStyle = "black";
        for (int line = 0; line < prog.length; line++) {
          ctx.fillText(prog[line], lx, ly);
          ly += 20;
        }
      }
      ctx.restore();
    }    
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    super.draw(ctx);
    if (ghost != null) ghost.draw(ctx);
  }
  
  
  void _drawLocal(CanvasRenderingContext2D ctx) {
    
    //---------------------------------------------
    // draw sound wave
    //---------------------------------------------
    if (_radius > 0) {
      num alpha = 1 - (_radius / 175.0);
      ctx.strokeStyle = "rgba(255, 255, 255, $alpha)";
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.arc(0, 0, _radius, 0, PI * 2, true);
      ctx.stroke();
    }
    /*
    for (Frog frog in pond.getFrogsHere(this)) {
      double angle = angleBetween(frog);
      if (angle.abs() < 90.0) {
        angle = angle / 180.0 * PI;
        double dx = radius * 2 * sin(-angle);
        double dy = radius * 2 * cos(-angle);
        ctx.lineWidth = 3;
        ctx.strokeStyle = 'white';
        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.lineTo(dx, -dy);
        ctx.stroke();
      }
    }
    
    ctx.strokeStyle = 'white';
    if (pond.getFrogsHere(this).isNotEmpty) {
      ctx.strokeStyle = 'cyan';
    }
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(0, 0, radius, 0, PI * 2, true);
    ctx.stroke();
    */
    
    //---------------------------------------------
    // draw vision cone
    //---------------------------------------------
    if (vision > 0) {
      double theta = vision / 180.0 * PI;
      double r = height * 1.5;
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.arc(0, 0, r, PI * -0.5 - theta, PI * -0.5 + theta, false);
      ctx.closePath();
      ctx.fillStyle = "rgba(255, 255, 255, 0.1)";
      ctx.fill();
    }
    
    
    //---------------------------------------------
    // draw tongue sticking out
    //---------------------------------------------
    if (tongue > 0) {
      ctx.strokeStyle = "#922";
      ctx.lineWidth = 5;
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(0, tongue * height * -1.5);
      ctx.stroke();
    }
    
    //---------------------------------------------
    // draw frog image
    //---------------------------------------------
    num iw = width;
    num ih = height;
    ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
  }
  
  
  void doCommand(String cmd, Parameter param, [ bool preview = false ]) {
    opacity = 1.0;
    ghost = null;
    if (cmd == "hop") {
      doMove(cmd, param, preview);
    } else if (cmd == "left" || cmd == "right") {
      doTurn(cmd, param, preview);
    } else if (cmd == "chirp") {
      doSound(cmd);
    } else if (cmd == "rest") {
      doRest(cmd);
    } else if (cmd == "eat") {
      doEat(cmd);
    } else if (cmd == "hatch") {
      doHatch(cmd, preview);
    } else if (cmd == "end") {
      _pause();
    }
  }
  
  
  void _pause() {
    tween = new Tween();
    tween.delay = 0;
    tween.duration = 20;
    tween.onstart = (() { });
    tween.onend = (() {
      opacity = 1.0;
      ghost = null;
      _radius = -1.0;
      vision = -1.0;
      tongue = 0.0;
      label = null;
    });
  }
  

  void doMove(String cmd, Parameter param, [ bool preview = false ]) {
    Frog target = this;
    if (preview) {
      ghost = hatch();
      ghost.opacity = 0.3;
      target = ghost;
    }
    double length = height * 0.4;
    if (param.value is num) {
      length *= param.value;
    }
    String s = "$cmd ${param.value}";
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 12;
    tween.onstart = (() { Sounds.playSound(cmd); target.label = s; });
    tween.onend = (() {
      _pause();
      if (pond.inWater(x, y)) {
        Sounds.playSound("splash");
        die();
      } else {
        Gem gem = pond.getGemHere(this);
        if (gem != null) {
          workspace.captureGem(gem);
        }
      }
    });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(length, 1);
    tween.ondelta = ((value) => target.forward(value));
  }
  

  void doSound(String cmd) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.onstart = (() { Sounds.playSound(cmd); label = cmd; _radius = 0.5; });
    tween.onend = (() { _radius = -1.0; _pause(); });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(175, 1);
    tween.duration = 25;
    tween.delay = 0;
    tween.ondelta = ((value) => _radius += value);
  }
  
  
  void doEat(String cmd) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.onstart = (() { label = cmd; tongue = 0.0; });
    tween.addControlPoint(0.0, 0.0);
    tween.addControlPoint(1.0, 0.4);
    tween.addControlPoint(0.0, 1.0);
    tween.duration = 20;
    tween.ondelta = ((value) {
      tongue += value;
      if (prey == null) {
        prey = pond.getFlyHere(tongueX, tongueY);
      } else {
        prey.x = tongueX;
        prey.y = tongueY;
      }
      if (tongue == 1.0) Sounds.playSound("swoosh");
    });
    tween.onend = (() {
      if (prey != null) {
        Sounds.playSound("gulp");
        workspace.captureFly(prey);
        prey = null;
      }
      _pause();
    });
  }


  void doTurn(String cmd, Parameter param, [ bool preview = false ]) {
    num angle = 30;
    if (param.value is num) {
      angle = param.value;
    } else if (param.valueAsString == 'random') {
      angle = Turtle.rand.nextInt(90).toDouble();
    }
    if (cmd == 'right') {
      angle *= -1;
    }
    Frog target = this;
    if (preview) {
      ghost = hatch();
      opacity = 0.3;
      target = ghost;
    }
    String s = "$cmd ${param.valueAsString}";
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 20;
    tween.onstart = (() => target.label = s);
    tween.addControlPoint(0, 0);
    tween.addControlPoint(angle, 1);
    tween.ondelta = ((value) => target.left(value));
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
  
  
  //void doWait(String cmd, Parameter param, [ bool preview = false ]) {
  void doWait(String cmd, [ bool preview = false ]) {
    num duration = 0;
    /*
    if (param.value is num) {
      duration = 25 * param.value;
    } else if (param.value == 'random') {
      duration = Turtle.rand.nextInt(100);
    } else if (param.value == 'fly') {
      vision = 10.0;
      if (preview) duration = 30;
    }
    */
    vision = 10.0;
    tween = new Tween();
    tween.duration = duration;
    tween.onstart = (() => label = cmd);
    tween.onend = (() {
      if (duration > 0 || preview) {
        label = null;
        vision = 0.0;
      }
    });
  }
  
  
  void doRepeat(String cmd, Parameter param) {
    tween = new Tween();
    tween.delay = 0;
    tween.duration = 5;
    tween.onstart = (() => label = cmd);
    tween.onend = (() { _pause(); });
  }
  

  void doHatch(String cmd, [ bool preview = false ]) {
    Frog baby = hatch();
    if (preview) {
      ghost = baby;
    } else {
      pond.addFrog(baby);
    }
    baby.size = 0.05;
    baby.left(Turtle.rand.nextInt(360).toDouble());
    baby.forward(35.0);
    tween = new Tween();
    tween.function = TWEEN_DECAY;
    tween.delay = 0;
    tween.duration = 15;
    tween.onstart = (() => label = cmd);
    tween.onend = (() {
      _pause();
      if (program != null) {
        baby.program = new Program.copy(baby, program);
        //baby.program.skip();
      }
    });
    tween.addControlPoint(0.05, 0);
    tween.addControlPoint(size + Turtle.rand.nextDouble() * 0.2 - 0.1, 1.0);
    tween.ondelta = ((value) => baby.size += value);
  }
  
  
  bool down = false;
  
  bool containsTouch(Contact c) {
    return overlapsPoint(c.touchX, c.touchY);
  }
  
  bool touchDown(Contact c) {
    down = true;
    return true;
  }
  
  void touchUp(Contact c) {
    down = false;
  }
  
  void touchDrag(Contact c) { }
  
  void touchSlide(Contact c) { }
}
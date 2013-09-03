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

  /* size of the sound wave emanating from the frog */
  double _radius = -1.0;
  
  /* length of the tongue coming out of the frog */
  double _tongue = 0.0;
  
  /* angle extent +/- of vision cone */
  double _vision = -1.0;

  /* name of the command being executed */
  String label = null;
  
  /* saved state of this frog (for previewing) */
  Frog ghost = null;
  
  /* this frogs control program */
  Program program;
  
  /* Fly captured by frog for eating */
  Fly prey = null;
  
  
  Frog(this.pond) : super() {
    img.src = "images/bluefrog.png";
  }
  
  
  Frog hatch() {
    Frog clone = new Frog(pond);
    clone.copy(this);
    clone.program = new Program.copy(program, clone);
    return clone;
  }
  
  
  double get tongueX => x + sin(heading) * _tongue * height * 1.5;
  
  double get tongueY => y - cos(heading) * _tongue * height * 1.5;
  
  double get radius => super.radius * 0.75;
  
  
  void reset() {
    opacity = 1.0;
    ghost = null;
    _radius = -1.0;
    _vision = -1.0;
    _tongue = 0.0;
    label = null;
  }
  
  
  bool animate() {
    return program.animate();
  }
  

/**
 * Push other frogs out of the way
 */
  void push(num distance) {
    /*
    for (Frog frog in pond.getFrogsHere(this)) {
      double angle = angleBetween(frog);
      if (angle.abs() < 90.0) {
        angle = angle / -180.0 * PI;
        angle += heading;
        double dx = distance * sin(angle);
        double dy = distance * cos(angle);
        frog.x += dx;
        frog.y -= dy;
        if (pond.inWater(frog.x, frog.y)) {
          Sounds.playSound("splash");
          frog.die();
        }
      }
    }
    */
  }
  
  
  
  bool nearWater() {
    forward(60.0);
    bool wet = pond.inWater(x, y);
    backward(60.0);
    return wet;
  }
  
  
  bool inWater() {
    return pond.inWater(x, y);
  }
  
  
  bool seeGem() {
    for (Gem gem in pond.gems) {
      if (angleBetween(gem).abs() < 20.0) return true;
    }
    return false;
  }
  
  
  void captureGem() {
    Gem gem = pond.getGemHere(this);
    if (gem != null) pond.captureGem(this, gem);
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
  
  
  void eatFly() {
    if (prey == null) {
      Fly fly = pond.getFlyHere(tongueX, tongueY);
      if (fly != null && !fly.dead) {
        prey = fly.hatch();
        pond.captureFly(this, fly);
      }
    } else {
      prey.x = tongueX;
      prey.y = tongueY;
    }
  }
  
  
  bool hearSound() {
    return false;
  }
  
  
  void drawProgram(CanvasRenderingContext2D ctx) {
/*
    if (program != null) {
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
*/
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    if (prey != null) prey.draw(ctx);
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

    
    //---------------------------------------------
    // draw vision cone
    //---------------------------------------------
    if (_vision > 0) {
      double theta = _vision / 180.0 * PI;
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
    if (_tongue > 0) {
      ctx.strokeStyle = "#922";
      ctx.lineWidth = 5;
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(0, _tongue * height * -1.5);
      ctx.stroke();
    }

    
    //---------------------------------------------
    // draw frog image
    //---------------------------------------------
    num iw = width;
    num ih = height;
    ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
  }
  

  bool containsTouch(Contact c) {
    return overlapsPoint(c.touchX, c.touchY);
  }
  
  bool touchDown(Contact c) { return true; }
  void touchUp(Contact c) { }
  void touchDrag(Contact c) { }
  void touchSlide(Contact c) { }
}
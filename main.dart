library ComputerHistory;

import 'dart:html';
import 'dart:math';
import 'dart:json';
import 'dart:web_audio';

part 'color.dart';
part 'turtle.dart';
part 'tween.dart';
part 'model.dart';
part 'toolbar.dart';
part 'button.dart';
part 'JsonObject.dart';
part 'nettango.dart';
part 'sounds.dart';
part 'touch.dart';

void main() {

  TouchManager.init();
  
  Sounds.loadSound("hop");
  Sounds.loadSound("skip");
  Sounds.loadSound("jump");
  Sounds.loadSound("croak");
  Sounds.loadSound("sing");
  Sounds.loadSound("chirp");
  Sounds.loadSound("turn");
  
   FrogPond model = new FrogPond();
   NetTango ntango = new NetTango(model);
   ntango.showToolbar();
   ntango.restart();
}
   

class FrogPond extends Model { 
   
   FrogPond() : super() {  }
   
   
   void setup() {
     clearTurtles();
     addTurtle(new Frog(this));
     //addTurtle(new GreenFrog(this));
     addTurtle(new PurpleFrog(this));
  }
}


class GreenFrog extends Frog {
   
   GreenFrog(Model model) : super(model) {
     x = -3;
     y = 3;
     img.src = "images/greenfrog.png";
     // 5. commands = [ "hop", "wait-sound", "croak" ];
     commands = [ "wait-sound", "turn-sound", "hop" ];
   }
}


class PurpleFrog extends Frog {
  PurpleFrog(Model model) : super(model) {
    x = 2;
    y = 1;
    img.src = "images/purplefrog.png";
    // 7. commands = [ "hop", "hop", "hop", "turn", "hatch", "chirp", "wait" ];
    commands = [ "hop", "wait", "if-sound", "hatch", "turn" ];
  }
  
  
  void reproduce() {
    PurpleFrog copy = new PurpleFrog(model);
    copy.x = x;
    copy.y = y;
    copy.right(rand.nextInt(360));
    model.addTurtle(copy);
  }
}

class Frog extends Turtle {
  
  ImageElement img;
  Tween tween;
  //List commands = ["skip", "skip", "hatch" ];
  // 1. List commands = [ "hop" ];
  // 2. List commands = [ "jump", "croak"]; 
  // 3. List commands = [ "turn", "hop" ];
  // 4. List commands = ["if-edge", "turn", "jump" ];
  // 5. List commands = [ "chirp", "wait" ];
  // 6. List commands = [ "turn", "skip", "chirp" ];
  List commands = [ "chirp", "wait" ];
  
  int cindex = 0;
  Random rand;
  num radius = -1;
  String label = null;
  
  Frog(Model model) : super(model) {
    img = new ImageElement();
    rand = new Random();
    right(rand.nextInt(360));
    img.src = "images/bluefrog.png"; 
    doCommand("wait");
  }
  
  void doCommand(String cmd) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 8;
    tween.duration = 20;
    tween.onstart = (() => label = cmd);
    tween.onend = (() { Sounds.playSound(cmd); label = null; radius = -1; transition(); });
    
    if (cmd == "jump") {
      tween.addControlPoint(0, 0);
      tween.addControlPoint(2, 1);
      tween.ondelta = ((value) => forward(value));
    }
    else if (cmd == 'hop') {
      tween.addControlPoint(0, 0);
      tween.addControlPoint(1, 1);
      tween.duration = 5;
      tween.ondelta = ((value) => forward(value));
    }
    else if (cmd == 'skip') {
      tween.addControlPoint(0, 0);
      tween.addControlPoint(1.5, 1);
      tween.duration = 10;
      tween.ondelta = ((value) => forward(value));
    }
    else if (cmd == 'turn') {
      tween.addControlPoint(0, 0);
      tween.addControlPoint(180 * rand.nextDouble() - 90, 1);
      tween.duration = 20;
      tween.ondelta = ((value) => right(value));
      tween.onend = (() { label = null; radius = -1; transition(); });
    }
    else if (cmd == 'turn-sound') {
      Frog target = hearSound();
      num angle = -1 * atan2(target.x - x, target.y - y);
      if (angle < 0) angle += 2*PI;
      num delta = angle - heading;
      
      // turn in the shortest direction to the target 
      if (delta > PI) delta -= 2*PI;
      if (delta < -PI) delta += 2*PI;
      
      // turn at most 45 degrees in either direction
      delta = min( max(delta, -PI/4), PI/4);
      tween.addControlPoint(0, 0);
      tween.addControlPoint(delta, 1);
      tween.duration = 20;
      tween.ondelta = ((value) => right(value / PI * 180));
    }
    else if (cmd == 'sing') {
      tween.addControlPoint(0, 0);
      tween.addControlPoint(5, 1);
      tween.duration = 50;
      tween.delay = 0;
      tween.ondelta = ((value) => radius += value);
      tween.onstart = (() { label = cmd; radius = 0.5; Sounds.playSound(cmd); });
      tween.onend = (() { radius = -1; label = null; transition(); });
    }
    else if (cmd == 'chirp') {
      tween.addControlPoint(0, 0);
      tween.addControlPoint(5, 1);
      tween.duration = 50;
      tween.delay = 0;
      tween.ondelta = ((value) => radius += value);
      tween.onstart = (() { label = cmd; radius = 0.5; Sounds.playSound(cmd); });
      tween.onend = (() { radius = -1; label = null; transition(); });
    }
    else if (cmd == 'croak') {
      tween.addControlPoint(0, 0);
      tween.addControlPoint(5, 1);
      tween.duration = 50;
      tween.delay = 0;
      tween.ondelta = ((value) => radius += value);
      tween.onstart = (() { label = cmd; radius = 0.5; Sounds.playSound(cmd); });
      tween.onend = (() { radius = -1; label = null; transition(); });
    }
    else if (cmd == 'if-edge') {
      if (nearEdge()) {
        doCommand(commands[cindex + 1]);
      } else {
        doCommand(commands[cindex + 2]);
      }
      cindex += 2;
    }
    else if (cmd == 'if-sound') {
      if (hearSound() != null) {
        doCommand(commands[cindex + 1]);
      } else {
        doCommand(commands[cindex + 2]);
      }
      cindex += 2;
    }
    else if (cmd == 'wait-sound') {
      if (hearSound() != null) {
        tween.duration = 1;
        tween.delay = 0;
        tween.onend = (() { radius = -1; label = null; transition(); });
      } else {
        tween.duration = 1;
        tween.delay = 0;
        tween.onstart = (() { label = 'wait for sound'; radius = -1; });
        tween.onend = (() { cindex--; transition(); });
      }
    }
    else if (cmd == 'hatch') {
      reproduce();
      tween.duration = 1;
      tween.delay = 0;
      tween.onend = transition;
    }
    else if (cmd == 'wait') {
      tween.duration = rand.nextInt(100) + 30;
      tween.onstart = null;
      tween.onend = (() { radius = -1; label = null; transition(); });
    }
    tween.play();
  }
  
  void transition() {
    doCommand(commands[cindex]);
    cindex = (cindex + 1) % commands.length;
  }
  
   
  void draw(var ctx) {
    if (radius > 0) {
      num alpha = 1 - (radius / 5);
      ctx.strokeStyle = "rgba(255, 255, 255, $alpha)";
      ctx.lineWidth = 0.2;
      ctx.beginPath();
      ctx.arc(0, 0, radius, 0, PI * 2, true);
      ctx.stroke();
    }
    if (label != null) {
      ctx.save();
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.textBaseline = "top";
      ctx.textAlign = "center";
      ctx.fillStyle = "white";
      ctx.font = "16px helvetica, sans-serif";
      ctx.fillText(label, model.worldToScreenX(x, y), model.worldToScreenY(x, y) + 65);
      ctx.restore();
    }
    num iw = img.width / 70;
    num ih = img.height / 70;
    ctx.drawImage(img, -iw/2, -ih/2, iw, ih);
  }
   
  void tick() {
    tween.animate();
    if (x < model.minWorldX || x > model.maxWorldX || y < model.minWorldY || y > model.maxWorldY){
      die();
    }
  }
  
  
  bool nearEdge() {
    num px = (x - sin(heading) * 2.5);
    num py = (y + cos(heading) * 2.5);
    return (px > model.maxWorldX || px < model.minWorldX || py > model.maxWorldY || py < model.minWorldY);
  }
  
  
  Frog hearSound() {
    for (var frog in model.turtles) {
      if (frog != this && frog.radius > 0) {
        num d2 = (x - frog.x) * (x - frog.x) + (y - frog.y) * (y - frog.y);
        if (frog.radius * frog.radius >= d2) return frog;
      }
    }
    return null;
  }
   
   void reproduce() {
      Frog copy = new Frog(model);
      copy.x = x;
      copy.y = y;
      copy.heading = rand.nextInt(360);
      model.addTurtle(copy);
   }
}
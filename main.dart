library ComputerHistory;

import 'dart:html';
import 'dart:math';
import 'dart:json';
import 'dart:async';
import 'dart:web_audio';
import '../NetTangoJS/core/ntango.dart';

part 'tween.dart';
part 'sounds.dart';


WebSocket socket = null;


void main() {

  Sounds.loadSound("hop");
  Sounds.loadSound("skip");
  Sounds.loadSound("jump");
  Sounds.loadSound("croak");
  Sounds.loadSound("sing");
  Sounds.loadSound("chirp");
  Sounds.loadSound("splash");
  Sounds.loadSound("turn");

  FrogPond model = new FrogPond();
  model.restart();

/*  
  window.onMessage.listen((event) {
    if (event.data.startsWith("@dart")) {
      model.doCompile(event.data.substring(5));
    }
  });
*/

  //--------------------------------------------------------------
  // attempt to connect to the websocket server
  //--------------------------------------------------------------
  socket = new WebSocket('ws://127.0.0.1:8887');
  socket.onOpen.listen((evt) { print ("Socket opened"); } );
  socket.onError.listen((evt) { print ("Socket error"); } );
  socket.onMessage.listen((evt) {
    print(evt.data);
    if (evt.data.startsWith("@dart RESTART")) {
      model.restart();
      sendMessage("RESTARTED");
    }
    else if (evt.data.startsWith("@dart PLAY")) {
      if (model.ticks == 0) {
        model.doCompile(evt.data.substring(11));
        sendMessage("STARTED");
      } else {
        model.doCompile(evt.data.substring(11));
        sendMessage("STARTED");
      }
    }
    else if (evt.data.startsWith("@dart PAUSE")) {
      model.pause();
      sendMessage("PAUSED");
    }
  });
}


void sendMessage(String message) {
  if (socket != null && socket.readyState == WebSocket.OPEN) {
    socket.send("@blockly $message");
  }
}



class FrogPond extends Model {
  
  FrogPond() : super("Frog Pond", "frog") {  
    wrap = false;
  }

  
  void setup() {
    clearTurtles();
  }
  
  
  void doCompile(String json) {
    var behaviors = json.split('\n');
    for (int i=0; i<behaviors.length && i<3; i++) {
      String behavior = '[ ${behaviors[i]} ]';
      String breed = 'breed$i';
      bool loaded = false;
      
      for (Frog frog in turtles) {
        if (frog.breed == breed) {
          frog.loadBehavior(behavior);
          loaded = true;
        }
      }
      
      // need to create a new breed?
      if (!loaded) {
        Frog frog = new Frog(this);
        frog.breed = breed;
        
        switch (i % 3) {
        case 0:
          frog.img.src = 'images/bluefrog.png';
          break;
        case 1:
          frog.img.src = 'images/purplefrog.png';
          break;
        case 2:
          frog.img.src = 'images/greenfrog.png';
          break;
        }
        frog.loadBehavior(behavior);
        addTurtle(frog);
      }
    }
    play(1);
  }

  
  bool isRunning() {
    for (Frog frog in turtles) {
      if (frog.running) return true;
    }
    return false;
  }
  
  
  void tick() {
    if (turtles.length > 100) {
      restart();
      sendMessage("RESTARTED");
    }
    else if (isRunning()) {
      super.tick();
    } else {
      pause();
      ticks = 0;
      sendMessage("DONE");
    }
  }
}


class Frog extends Turtle {

  ImageElement img;
  Tween tween;
  Random rand;
  num radius = -1;
  String label = null;
  bool running = false;


  Frog(Model model) : super(model) {
    img = new ImageElement();
    rand = new Random();
    right(rand.nextInt(360));
    img.src = "images/bluefrog.png";
    tween = new Tween();
    breed = "breed0";
    
    x = rand.nextDouble() * 16 - 8.0;
    y = rand.nextDouble() * 16 - 8.0;

    commands["hop"] = doMove;
    commands["skip"] = doMove;
    commands["jump"] = doMove;
    commands["sing"] = doSound;
    commands["chirp"] = doSound;
    commands["croak"] = doSound;
    commands["left"] = doLeft;
    commands["right"] = doRight;
    commands["turn-random"] = doTurnRandom;
    commands["wait-sound"] = doWaitSound;
    commands["rest"] = doRest;
    commands["hatch"] = doHatch;
    commands["near-edge"] = doNearEdge;
    commands["hear-sound"] = doHearSound;
    commands["turn-sound"] = doTurnSound;
  }
  

  void reproduce() {
    Frog copy = new Frog(model);
    copy.x = x;
    copy.y = y;
    copy.heading = rand.nextInt(360);
    copy.img.src = img.src;
    copy.breed = breed;
    copy.setBehavior(interp.program);
    model.addTurtle(copy);
  }
  
  
  void tick() {
    if (tween.isTweening()) {
      tween.animate();
    } else {
      running = interp.step();
    }
    if (x < model.minWorldX || x > model.maxWorldX || y < model.minWorldY || y > model.maxWorldY) {
      Sounds.playSound("splash");
      die();
    }
  }


  void loadBehavior(String code) {
    interp.loadJSON(code);
    running = true;
  }
  

  void doMove(String cmd, List args) {
    double length = 2.0;

    if (cmd == "hop") {
      length = 1.0; //0.5;
    } else if (cmd == "skip") {
      length = 1.0;
    } else {
      length = 2.0;
    }
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 10;
    tween.duration = (length * 10).toInt();
    tween.onstart = (() => label = cmd);
    tween.onend = (() { Sounds.playSound(cmd); label = null; radius = -1; });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(length, 1);
    tween.duration = 5;
    tween.ondelta = ((value) => forward(value));
    tween.play();
  }


  void doSound(String cmd, List args) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.onstart = (() { label = cmd; radius = 0.5; Sounds.playSound(cmd); });
    tween.onend = (() { radius = -1; label = null; });
    tween.addControlPoint(0, 0);
    tween.addControlPoint(5, 1);
    tween.duration = 50;
    tween.delay = 20;
    tween.ondelta = ((value) => radius += value);
  }


  void doLeft(String cmd, List args) {
    num angle = rand.nextInt(100);
    if (args.length > 0 && args[0] is num) {
      angle = args[0];
    }
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 20;
    tween.duration = 20;
    tween.onstart = (() => label = cmd);
    tween.addControlPoint(0, 0);
    tween.addControlPoint(angle, 1);
    tween.ondelta = ((value) => left(value));
    tween.onend = (() { label = null; radius = -1; });
  }


  void doRight(String cmd, List args) {
    num angle = rand.nextInt(100);
    if (args.length > 0 && args[0] is num) {
      angle = args[0];
    }
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 20;
    tween.duration = 20;
    tween.onstart = (() => label = cmd);
    tween.addControlPoint(0, 0);
    tween.addControlPoint(angle, 1);
    tween.ondelta = ((value) => right(value));
    tween.onend = (() { label = null; radius = -1; });
  }

  
  void doTurnRandom(String cmd, List args) {
    num angle = rand.nextInt(140) - 70;
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 20;
    tween.duration = 20;
    tween.onstart = (() => label = cmd);
    tween.addControlPoint(0, 0);
    tween.addControlPoint(angle, 1);
    tween.ondelta = ((value) => left(value));
    tween.onend = (() { label = null; radius = -1; });
  }

  
  void doTurnSound(String cmd, List args) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 20;
    tween.duration = 20;
    tween.onstart = (() => label = cmd);
    tween.onend = (() { label = null; radius = -1; });
    
    if (cmd == 'turn-sound') {
      Frog target = hearFrog();
      if (target != null) {
        num angle = -1 * atan2(target.x - x, target.y - y) + PI;
        if (angle < 0) angle += 2*PI;
        num delta = angle - heading;

        // turn in the shortest direction to the target
        if (delta > PI) delta -= 2*PI;
        if (delta < -PI) delta += 2*PI;

        // turn at most 45 degrees in either direction
        delta = min( max(delta, -PI/4), PI/4);
        tween.addControlPoint(0, 0);
        tween.addControlPoint(delta, 1);
        tween.ondelta = ((value) => right(value / PI * 180));
      }
    }
  }
  

  void doRest(String cmd, List args) {
    int duration = rand.nextInt(50) + 30;
    if (args.length > 0 && args[0] is num) {
      duration = args[0].toInt();
    }
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 10;
    tween.duration = duration;
    tween.onstart = (() => label = cmd);
    tween.onend = (() { radius = -1; label = null; });
  }
  

  void doWaitSound(String cmd, List args) {  
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 0;
    tween.duration = 1;
    tween.repeat = REPEAT_FOREVER;
    tween.onstart = (() => label = cmd);
    tween.ondelta = ((value) {
      if (hearFrog() != null) {
        tween.repeat = 1;
        tween.stop();
        radius = -1;
        label = null;
      }
    });
  }
  
  
  bool doNearEdge(String cmd, List args) {
    num px = (x - sin(heading) * 2.5);
    num py = (y + cos(heading) * 2.5);
    return (px > model.maxWorldX || px < model.minWorldX || py > model.maxWorldY || py < model.minWorldY);
  }
  
  
  bool doHearSound(String cmd, List args) {
    return (hearFrog() != null);
  }
  
  
  Frog hearFrog() {
    for (Frog frog in model.turtles) {
      if (frog != this && frog.radius > 0) {
        num d2 = (x - frog.x) * (x - frog.x) + (y - frog.y) * (y - frog.y);
        if (frog.radius * frog.radius >= d2) {
          return frog;
        }
      }
    }
    return null;    
  }


  void doHatch(String cmd, List args) {
    int duration = rand.nextInt(50) + 30;
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 10;
    tween.duration = duration;
    tween.onstart = (() => label = null);
    tween.onend = (() { radius = -1; label = null; reproduce(); });
  }


  void doCommand(String cmd) {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 8;
    tween.duration = 20;
    tween.onstart = (() => label = cmd);
    tween.onend = (() { Sounds.playSound(cmd); label = null; radius = -1; });
    tween.play();
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
    ctx.drawImageScaled(img, -iw/2, -ih/2, iw, ih);
  }

}
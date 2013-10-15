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


class FrogPond extends TouchLayer {
  
  CanvasElement canvas;
  CanvasRenderingContext2D layer0;  // lilypads
  CanvasRenderingContext2D layer1;  // frogs
  CanvasRenderingContext2D layer2;  // flies
  
  TouchManager tmanager = new TouchManager();
  
  List<CodeWorkspace> workspaces = new List<CodeWorkspace>();
  
  int width, height;
  
  /* List of flies */  
  List<Fly> flies = new List<Fly>();
  
  /* List of frogs */  
  List<Frog> frogs = new List<Frog>();
  
  /* List of lilypads */
  List<LilyPad> pads = new List<LilyPad>();
  
  /*
   * Play state
   *   -2 : play backward 2x
   *   -1 : play backward normal speed
   *   0  : paused
   *   1  : play forward normal speed
   *   2  : play forward 2x
   *   4  : play forward 4x ....
   */
  int play_state = 1; 
  
  /* Master timeout to restart exhibit after 80 seconds of inactivity */
  int _countdown = 0;
  
  ImageElement pond = new ImageElement();
  
  
  FrogPond() {
    canvas = document.query("#pond");
    layer0 = canvas.getContext('2d');
    
    canvas = document.query("#frogs");
    layer1 = canvas.getContext('2d');
    
    canvas = document.query("#flies");
    layer2 = canvas.getContext('2d');
    
    width = canvas.width;
    height = canvas.height;
    
    tmanager.registerEvents(document.documentElement);
    tmanager.addTouchLayer(this);
    
    addLilyPad(300, height/2, 0.6);
    addLilyPad(370, 100, 0.6);
    addLilyPad(1620, height/2, 0.6);
    addLilyPad(550, 790, 0.8);
    addLilyPad(630, 370, 0.9);
    addLilyPad(940, 650, 0.8);
    addLilyPad(1000, 250, 0.8);
    addLilyPad(1300, height/2, 0.8);
    addLilyPad(1400, 130, 0.6);
    addLilyPad(1300, height - 130, 0.6);
    addLilyPad(900, height - 130, 0.6);
    

    CodeWorkspace workspace = new CodeWorkspace(this, width, height, "workspace1", "blue");
    tmanager.addTouchLayer(workspace);
    workspaces.add(workspace);
    
    for (int i=0; i<12; i++) {
      addFly();
    }

    new Timer.periodic(const Duration(milliseconds : 40), tick);
    new Timer.periodic(const Duration(seconds : 2), (timer) => drawPond(layer0));
  }
  
  
/**
 * Add a frog to the pond
 */
  void addRandomFrog(CodeWorkspace workspace) {
    for (int i=0; i<20; i++) {
      int x = Turtle.rand.nextInt(width - 200) + 100;
      int y = Turtle.rand.nextInt(height - 300) + 150;
      if (!inWater(x, y)) {
        Frog frog = new Frog(this);
        frog["workspace"] = workspace.name;
        frog.x = x.toDouble();
        frog.y = y.toDouble();
        frog.program = new Program(workspace.start, frog);
        frog.img.src = "images/${workspace.color}frog.png";
        addFrog(frog);
        return;
      }
    }

    // try again in 2 seconds
    new Timer(const Duration(milliseconds : 2000), () => addRandomFrog(workspace));
  }
  
  
/**
 * Adds a new frog for the given workspace
 */
  Frog addHomeFrog(CodeWorkspace workspace) {
    Frog frog = new Frog(this);
    frog["workspace"] = workspace.name;
    double fx = workspace.width / 2;
    double fy = workspace.height - 300.0;
    frog.x = workspace.objectToWorldX(fx, fy);
    frog.y = workspace.objectToWorldY(fx, fy);
    frog.heading = workspace.objectToWorldTheta(0);
    frog.program = new Program(workspace.start, frog);
    frog.img.src = "images/${workspace.color}frog.png";
    addFrog(frog);
    return frog;
  }
  

/**
 * Add an existing frog to the pond
 */
  void addFrog(Frog frog) {
    frogs.add(frog);
    addTouchable(frog);
  }
  
  
/**
 * Count the number of frogs of a given color
 */
  int getFrogCount([String workspaceName = null]) {
    if (workspaceName == null) {
      return frogs.length;
    } else {
      int count = 0;
      for (Frog frog in frogs) {
        if (frog["workspace"] == workspaceName) {
          count++;
        }
      }
      return count;
    }
  }
  

/**
 * Frog to trace program execution
 */
  Frog getFocalFrog(String workspace) {
    for (Frog frog in frogs) {
      if (frog["workspace"] == workspace) {
        return frog;
      }
    }
    return null;
  }
  
  
/**
 * Remove a frog from the pond
 */
  void removeFrog(Frog frog) {
    frogs.remove(frog);
    removeTouchable(frog);
  }
  

/**
 * Remove dead frogs
 */
  bool removeDeadFrogs() {
    int count = 0;
    for (int i=frogs.length-1; i >= 0; i--) {
      if (frogs[i].dead) {
        removeFrog(frogs[i]);
        count++;
      }
    }
    return count > 0;
  }
  
  
/**
 * Returns all frogs at the given location (not including the original frog)
 */
  Set<Frog> getFrogsHere(Turtle turtle) {
    Set<Frog> aset = new HashSet<Frog>();
    for (Frog f in frogs) {
      if (f != turtle && f.overlapsTurtle(turtle)) {
        aset.add(f);
      }
    }
    return aset;
  }


/**
 * Returns one frog at the given location
 */
  Frog getFrogHere(num x, num y) {
    for (Frog frog in frogs) {
      if (frog.overlapsPoint(x, y)) return frog;
    }
    return null;
  }
  
  
/**
 * Show frog histogram
 */
  void census() {
    frogs.sort((Frog a, Frog b) => (b.size * 100 - a.size * 100).toInt());
    double fx = 0.0, fy = 0.0;
    double cx = width / 6;
    double m = sqrt(3.0);
    double interval = m / 4;
    for (Frog frog in frogs) {
      for (int i=1; i<=4; i++) {
        if (frog.size < interval * i || i == 4) {
          fx = cx * i + Turtle.rand.nextInt(150) - 75;
          fy = height / 2 + Turtle.rand.nextInt(200 - 100);
          break;
        }
      }
    
      if (frog._saveX != null) {
        frog.flyBack();
      } else {
        frog.flyTo(fx, fy);
      }
    }
  }
  
  
/**
 * Preview a programming command
 */
  void previewBlock(String workspace, String cmd, var param) {
    for (Frog frog in frogs) {
      if (frog["workspace"] == workspace) {
        frog.program.doCommand(cmd, param, true);
      }
    }
  }


  void playProgram(CodeWorkspace workspace) {
    int count = getFrogCount(workspace.name);
    if (count == 0) addHomeFrog(workspace);
    for (Frog frog in frogs) {
      if (frog["workspace"] == workspace.name) {
        frog.program.play();
      }
    }
  }
  
  
  void pauseProgram(CodeWorkspace workspace) {
    play_state = 1;
    Sounds.mute = false;
    for (Frog frog in frogs) {
      if (frog["workspace"] == workspace.name) {
        frog.program.pause();
      }
    }
  }
  
  
  void stopProgram(CodeWorkspace workspace) {
    for (Frog frog in frogs) {
      if (frog["workspace"] == workspace.name) {
        frog.program.restart();
      }
    }
  }
  
  
  void restartProgram(CodeWorkspace workspace) {
    for (Frog frog in frogs) {
      if (frog["workspace"] == workspace.name) {
        frog.die();
      }
    }
    for (int i=0; i<4; i++) {
      addRandomFrog(workspace);
    }
  }
  
  
  void fastForwardProgram(CodeWorkspace workspace) {
    Sounds.mute = false;
    if (play_state <= 0) {
      play_state = 1;
    } else if (play_state < 64) {
      play_state *= 2;
      Sounds.mute = true;
    } else {
      play_state = 1;
    }
    drawForeground();
  }
  
  
/**
 * Are all programs paused?
 */
  bool isProgramPaused(String workspaceName) {
    for (Frog frog in frogs) {
      if (frog["workspace"] == workspaceName) {
        if (!frog.program.isPaused) return false;
      }
    }
    return true;
  }
  
  
/**
 * Are all programs finished running?
 */
  bool isProgramFinished(String workspaceName) {
    for (Frog frog in frogs) {
      if (frog['workspace'] == workspaceName) {
        if (!frog.program.isFinished) return false;
      }
    }
    return true;
  }
  
  
/**
 * Is there a frog still running a program?
 */
  bool isProgramRunning(String workspaceName) {
    bool running = false;
    for (Frog frog in frogs) {
      if (frog['workspace'] == workspaceName) {
        if (frog.program.isRunning) running = true;
      }
    }
    return running;
  }
  
  
  void addLilyPad([num lx = null, num ly = null, num ls = null]) {
    LilyPad pad = new LilyPad(this);
    if (lx == null) lx = Turtle.rand.nextInt(width).toDouble();
    if (ly == null) ly = Turtle.rand.nextInt(height).toDouble();
    if (ls == null) ls = 0.6 + Turtle.rand.nextDouble() * 0.4;
    pad.x = lx;
    pad.y = ly;
    pad.size = ls;
    pad.refresh = true;
    pads.add(pad);
    addTouchable(pad);
  }

  
/**
 * Adds a new random fly to the pond
 */
  void addFly() {
    flies.add(new Fly(this,
                      Turtle.rand.nextInt(width).toDouble(),
                      Turtle.rand.nextInt(height).toDouble()));
  }
  
  
/**
 * Remove dead flies
 */
  void removeDeadFlies() {
    for (int i=flies.length-1; i >= 0; i--) {
      if (flies[i].dead) flies.removeAt(i);
    }
  }


/**
 * Returns the fly at the given location
 */
  Fly getFlyHere(num x, num y) {
    for (Fly fly in flies) {
      if (fly.overlapsPoint(x, y, 30)) return fly;
    }
    return null;
  }
  
  
/**
 * Capture a fly
 */
  void captureFly(Frog frog, Fly fly) {
    fly.die();
    addFly();
  }
  
  
/**
 * Animate and draw
 */
  void tick(Timer timer) {
    flies.forEach((fly) => fly.erase(layer2));
    
    // animate lilypad movement
    bool refresh = false;
    for (LilyPad pad in pads) {
      if (pad.refresh) {
        refresh = true;
        pad.refresh = false;
      }
    }
    
    if (refresh) drawPond(layer0);
    refresh = false;
    
    for (int i=0; i<play_state; i++) {
      if (animate()) refresh = true;
    }
    if (refresh) drawForeground();
    flies.forEach((fly) => fly.draw(layer2));
    
    // animate code workspaces
    for (CodeWorkspace workspace in workspaces) {
      if (getFrogCount(workspace.name) == 0) {
        restartProgram(workspace);
      }
      if (workspace.animate()) {
        workspace.draw();
      }
    }
  }
  
  
/**
 * Animate all of the agents and the workspaces
 */
  bool animate() {
    bool refresh = false;

    // remove dead frogs and flies
    removeDeadFlies();
    removeDeadFrogs();
    
    flies.forEach((fly) => fly.animate());

    // animate might add a new frog, so use a counting for loop
    for (int i=0; i<frogs.length; i++) {
      if (frogs[i].animate()) refresh = true;
    }

    for (CodeWorkspace workspace in workspaces) {    
      if (workspace.bug.animate()) refresh = true;
    }
    
    return refresh;
  }
  

/**
 * Returns true if the given point is in the water
 */
  bool inWater(num x, num y) {
    for (LilyPad pad in pads) {
      if (pad.overlapsPoint(x, y)) return false;
    }
    return true;
  }
  
  
  void drawHistogram(CanvasRenderingContext2D ctx) {
    if (frogs.length <= 0) return;
    var hist = [ 0, 0, 0, 0 ];
    double m = sqrt(3.0);
    double interval = m / 4;
    for (Frog frog in frogs) {
      for (int i=1; i<=4; i++) {
        if (frog.size <= interval * i || i == 4) {
          hist[i-1]++;
          break;
        }
      }
    }
    
    double start = 0.0;
    double sweep = 0.0;
    ctx.strokeStyle = "white";
    ctx.lineWidth = 3;
    ctx.textAlign = "left";
    ctx.font = "200 22px sans-serif";
    ctx.textBaseline = "bottom";

    for (int i=0; i<4; i++) {
      sweep = (hist[i] / frogs.length) * PI * 2;
      ctx.fillStyle = "rgba(${i * 70}, ${i * 20}, ${i * 40}, 0.7)";
      ctx.beginPath();
      ctx.moveTo(width - 175, 175);
      ctx.arc(width - 175, 175, 140, start, start + sweep, false);
      start += sweep;
      ctx.fill();
      ctx.fillRect(width - 250, 330 + 40 * i, 30, 30);
      ctx.fillStyle = "white";
      ctx.strokeRect(width - 250, 330 + 40 * i, 30, 30);
      String size = "Tiny";
      switch (i) {
        case 0: size = "Tiny"; break;
        case 1: size = "Small"; break;
        case 2: size = "Big"; break;
        default: size = "Huge"; break;
      }
      ctx.fillText("$size: ${(100.0 * hist[i] / frogs.length).toInt()}%", width - 210, 360 + 40 * i );
    }
    ctx.beginPath();
    ctx.arc(width - 175, 175, 140, 0, PI * 2, false);
    ctx.stroke();
  }
  
  
  void drawPond(CanvasRenderingContext2D ctx) {
    ctx.clearRect(0, 0, width, height);
    for (LilyPad pad in pads) {
      pad.draw(ctx);
    }
    drawHistogram(ctx);
  }
  
  
/**
 * Draws the flies, frogs, and programming blocks
 */
  void drawForeground() {
    CanvasRenderingContext2D ctx = layer1;
    ctx.clearRect(0, 0, width, height);

    frogs.forEach((frog) => frog.draw(ctx));
    
    if (play_state > 1) {
      ctx.font = "20px sans-serif";
      ctx.textAlign = "center";
      ctx.textBaseline = "top";
      ctx.fillStyle = "white";
      ctx.fillText("Speedup: x${play_state}", width / 2, 15);
    }
    
    for (CodeWorkspace workspace in workspaces) {
      Frog target = getFocalFrog(workspace.name);
      if (target != null) {
        if (target.ghost != null && target.ghost.label != null) {
          workspace.traceExecution(ctx, target.ghost);
        } else {
          workspace.traceExecution(ctx, target);
        }
        workspace.drawBug(ctx);
      }
    }
  }
}

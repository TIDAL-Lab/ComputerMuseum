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
  CanvasRenderingContext2D layer0;  // lily pads
  CanvasRenderingContext2D layer1;  // frogs / gems
  CanvasRenderingContext2D layer2;  // flies
  
  TouchManager tmanager = new TouchManager();
  
  List<CodeWorkspace> workspaces = new List<CodeWorkspace>();
  
  int width, height;
  
  /* List of gems on the screen */
  List<Gem> gems = new List<Gem>();

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
    

    if (!isFlagSet("evolution")) {
      addGem();
    }
    
    for (int i=0; i<12; i++) {
      addFly();
    }
  
    
    if (isFlagSet("evolution")) {
      addLilyPad(width/2, height/2, 1.0);
      addLilyPad(200, 200, 0.7);
      addLilyPad(900, 210, 0.7);
      addLilyPad(840, 550, 0.6);
    } else {
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
    }
    

    if (isFlagSet("evolution")) {
      MAX_FROGS = 100;
      CodeWorkspace workspace = new CodeWorkspace(this, width, height, "workspace1", "green");
      workspaces.add(workspace);
      tmanager.addTouchLayer(workspace);
      for (int i=0; i<4; i++) {
        addRandomFrog(workspace);
      }
    } else {
      CodeWorkspace workspace = new CodeWorkspace(this, height, width, "workspace1", "blue");
      workspace.transform(cos(PI / -2), sin(PI / -2), -sin(PI / -2), cos(PI / -2), 0, height);
      workspaces.add(workspace);
      tmanager.addTouchLayer(workspace);
      addHomeFrog(workspace);
  
      workspace = new CodeWorkspace(this, height, width, "workspace2", "green");
      workspace.transform(cos(PI/2), sin(PI/2), -sin(PI/2),cos(PI/2), width, 0);
      workspaces.add(workspace);
      tmanager.addTouchLayer(workspace);
      addHomeFrog(workspace);
    }

    new Timer.periodic(const Duration(milliseconds : 40), tick);
    
    // master timeout
    if (isFlagSet("timeout")) {
      print("initiating master restart timer");
      new Timer.periodic(const Duration(seconds : 10), (timer) {
        _countdown += 10;
        if (_countdown >= 80) window.location.reload();
      });
      document.documentElement.onMouseDown.listen((e) => _countdown = 0);
      document.documentElement.onTouchStart.listen((e) => _countdown = 0);
    }
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
    frogs.sort((Frog a, Frog b) => (a.size * 100 - b.size * 100).toInt());
    
    double range = 2.0 - 0.1;
    double interval = range / 5.0;  // eight bins
    double cutoff = 0.1 + interval;
    double fx = 0.0, fy = 0.0;
    
    for (Frog frog in frogs) {

      if (frog.size > cutoff) {
        fx += 90.0;
        fy = 0.0;
        cutoff += interval;
      }
      if (frog._saveX != null) {
        frog.flyBack();
      } else {
        frog.flyTo(fx + 300.0, height - 220.0 - fy, 0);
      }
      fy += 20;
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
    addHomeFrog(workspace).pulse();
  }
  
  
  void fastForwardProgram(CodeWorkspace workspace) {
    if (play_state <= 0) {
      play_state = 1;
    } else if (play_state < 64) {
      play_state *= 2;
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
      if (fly.overlapsPoint(x, y, 20)) return fly;
    }
    return null;
  }
  
  
/**
 * Capture a fly
 */
  void captureFly(Frog frog, Fly fly) {
    // first find the workspace
    for (CodeWorkspace workspace in workspaces) {
      if (workspace.name == frog["workspace"]) {
        workspace.captureFly();
        fly.die();
        addFly();
      }
    }
  }
  
  
/**
 * Adds a random gem to the pond in a place where there are no frogs... give up
 * after a few tries and try again later.
 */
  void addGem()  {
    for (int i=0; i<25; i++) {
      int x = Turtle.rand.nextInt(width - 100) + 50;
      int y = Turtle.rand.nextInt(height - 200) + 100;
      if (!inWater(x, y) && getFrogHere(x, y) == null) {
        Gem gem = new Gem();
        gem.x = x.toDouble();
        gem.y = y.toDouble();
        gem.size = 0.75;
        gems.add(gem);
        return;
      }
    }
    // try again in 4 seconds
    new Timer(const Duration(milliseconds : 4000), addGem);
  }

  
/**
 * Remove dead gems
 */
  void removeDeadGems() {
    for (int i=gems.length-1; i >= 0; i--) {
      if (gems[i].dead) gems.removeAt(i);
    }
  }
  
  
/**
 * Get any gem at this location 
 */
  Gem getGemHere(Frog frog) {
    for (Gem gem in gems) {
      if (gem.overlapsTurtle(frog) && !gem.dead) return gem;
    }
    return null;
  }
  
  
/**
 * Capture a gem
 */
  void captureGem(Frog frog, Gem gem) {
    // first find the workspace
    for (CodeWorkspace workspace in workspaces) {
      if (workspace.name == frog["workspace"]) {
        workspace.captureGem(gem);
        gem.die();
        new Timer(const Duration(milliseconds : 3000), () { addGem(); });
      }
    }
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
    
    if (refresh) {
      layer0.clearRect(0, 0, width, height);
      for (LilyPad pad in pads) {
        pad.draw(layer0);
      }
    }
    
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

    // remove dead frogs, flies, and gems
    removeDeadFlies();
    removeDeadGems();
    removeDeadFrogs();
    
    flies.forEach((fly) => fly.animate());
    
    // animate agents and workspaces
    for (Gem gem in gems) {
      if (gem.animate()) refresh = true;
    }

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
  
  
/**
 * Draws the flies, frogs, gems, and programming blocks
 */
  void drawForeground() {
    CanvasRenderingContext2D ctx = layer1;
    ctx.clearRect(0, 0, width, height);
    
    gems.forEach((gem) => gem.draw(ctx));
    
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

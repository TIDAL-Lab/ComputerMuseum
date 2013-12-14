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
  
  /* Histogram of frog populations */
  Histogram hist;
  
  
  
  FrogPond() {
    canvas = querySelector("#pond");
    layer0 = canvas.getContext('2d');
    
    canvas = querySelector("#frogs");
    layer1 = canvas.getContext('2d');
    
    canvas = querySelector("#flies");
    layer2 = canvas.getContext('2d');
    
    width = canvas.width;
    height = canvas.height;
    
    tmanager.registerEvents(querySelector("#workspace1"));
    tmanager.addTouchLayer(this);
    
    hist = new Histogram("plot", this);
    
    addLilyPad(732, 570, 0.35);
    addLilyPad(820, 390, 0.52);
    addLilyPad(848, 149, 0.475);
    addLilyPad(625, 181, 0.5);
    addLilyPad(609, 405, 0.4);
    addLilyPad(562, 570, 0.4);
    addLilyPad(361, 515, 0.475);
    addLilyPad(420, 145, 0.5);
    addLilyPad(248, 310, 0.4);
    addLilyPad(447, 328, 0.4);
    
    
    bindClickEvent("play-button", (event) => playPauseProgram());
    bindClickEvent("restart-button", (event) => restartProgram());
    bindClickEvent("fastforward-button", (event) => fastForwardProgram());
    bindClickEvent("plot-button", (event) {
      pauseProgram();
      hist.draw();
      setHtmlVisibility("overlay", true);
      setHtmlVisibility("plot-dialog", true);
      setHtmlOpacity("plot-dialog", 1.0);
    });
    bindClickEvent("close-button", (event) {
      setHtmlOpacity("plot-dialog", 0.0);
      new Timer(const Duration(milliseconds : 300), () {
        setHtmlVisibility("overlay", false);
        setHtmlVisibility("plot-dialog", false);
      });
    });

    
    CodeWorkspace workspace = new CodeWorkspace(this, "workspace1", "blue");
    tmanager.addTouchLayer(workspace);
    workspaces.add(workspace);
    
    for (int i=0; i<12; i++) {
      addFly();
    }
    
    // main animation timer
    new Timer.periodic(const Duration(milliseconds : 40), tick);
   
   
    // crude resource loading scheme 
    ImageElement loader = new ImageElement();
    loader.src = "images/lilypad.png";
    loader.onLoad.listen((event) {
      drawPond(layer0);
    });
    
    ImageElement loader2 = new ImageElement();
    loader2.src = "images/buildfrog.png";
    loader2.onLoad.listen((event) {
      drawForeground();
    });
  }
  
  
/**
 * Add a frog to the pond
 */
  void addRandomFrog(CodeWorkspace workspace) {
    String breed = workspace.color;
    for (int i=0; i<20; i++) {
      int x = rand.nextInt(width - 200) + 100;
      int y = rand.nextInt(height - 300) + 150;
      LilyPad pad = getLilyPadHere(x, y);
      if (pad != null) {
        Frog frog = new Frog(this);
        frog["breed"] = breed;
        frog.x = x.toDouble();
        frog.y = y.toDouble();
        frog.lilypad = pad;
        pad.addFrog(frog);
        frog.program = new Program(workspace.start, frog);
        frog.img.src = "images/${breed}frog.png";
        frogs.add(frog);
        addTouchable(frog);
        return;
      }
    }

    // try again in 2 seconds
    new Timer(const Duration(milliseconds : 2000), () => addRandomFrog(workspace));
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
  int getFrogCount([String breed = null]) {
    if (breed == null) {
      return frogs.length;
    } else {
      int count = 0;
      for (Frog frog in frogs) {
        if (frog["breed"] == breed) {
          count++;
        }
      }
      return count;
    }
  }
  

/**
 * Frog to trace program execution
 */
  Frog getFocalFrog(String breed) {
    for (Frog frog in frogs) {
      if (frog["breed"] == breed) {
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
 * Preview a programming command
 */
  void previewBlock(String breed, String cmd, var param) {
    for (Frog frog in frogs) {
      if (frog["breed"] == breed) {
        frog.program.doCommand(cmd, param, true);
      }
    }
  }
  
  
  void playPauseProgram() {
    if (isProgramRunning()) {
      pauseProgram();
    } else {
      playProgram();
    }
  }


  void playProgram() {
    for (Frog frog in frogs) {
      frog.program.play();
    }
  }
  
  
  void pauseProgram() {
    play_state = 1;
    Sounds.mute = false;
    for (Frog frog in frogs) {
      frog.program.pause();
    }
  }
  
  
  void stopProgram() {
    for (Frog frog in frogs) {
      frog.program.restart();
    }
  }
  
  
  void restartProgram() {
    play_state = 1;
    frogs.forEach((frog) => frog.die());
    for (LilyPad pad in pads) {
      pad.removeAllFrogs();
    }
    for (CodeWorkspace workspace in workspaces) {
      for (int i=0; i<4; i++) {
        addRandomFrog(workspace);
      }
    }
  }
  
  
  void fastForwardProgram() {
    Sounds.mute = false;
    if (play_state <= 0) {
      play_state = 1;
    } else if (play_state < 16) {
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
  bool isProgramPaused() {
    for (Frog frog in frogs) {
      if (!frog.program.isPaused) return false;
    }
    return true;
  }
  
  
/**
 * Are all programs finished running?
 */
  bool isProgramFinished() {
    for (Frog frog in frogs) {
      if (!frog.program.isFinished) return false;
    }
    return true;
  }
  
  
/**
 * Is there a frog still running a program?
 */
  bool isProgramRunning() {
    bool running = false;
    for (Frog frog in frogs) {
      if (frog.program.isRunning) running = true;
    }
    return running;
  }
  
  
  void addLilyPad([num lx = null, num ly = null, num ls = null]) {
    LilyPad pad = new LilyPad(this);
    if (lx == null) lx = rand.nextInt(width).toDouble();
    if (ly == null) ly = rand.nextInt(height).toDouble();
    if (ls == null) ls = 0.4 + rand.nextDouble() * 0.1;
    pad.x = lx.toDouble();
    pad.y = ly.toDouble();
    pad.size = ls;
    pad.refresh = true;
    pads.add(pad);
    addTouchable(pad);
  }

  
/**
 * Adds a new random fly to the pond
 */
  void addFly() {
    flies.add(new Fly(this, rand.nextInt(width).toDouble(), rand.nextInt(height).toDouble()));
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
    
    // animate frogs
    for (int i=0; i<play_state; i++) {
      if (animate()) refresh = true;
    }
    if (refresh) drawForeground();
    
    // draw flies
    flies.forEach((fly) => fly.draw(layer2));
    
    // animate code workspaces
    for (CodeWorkspace workspace in workspaces) {
      if (getFrogCount(workspace.color) == 0) {
        restartProgram();
      }
      if (workspace.animate()) {
        workspace.draw();
      }
    }
    
    // update play / pause button
    if (isProgramRunning()) {
      setHtmlBackground("play-button", "images/toolbar/pause.png");
    } else {
      setHtmlBackground("play-button", "images/toolbar/play.png");
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
    return (getLilyPadHere(x, y) != null);
  }
  
  
/**
 * Returns the topmost lilypad at the given point or null if none exists
 */
  LilyPad getLilyPadHere(num x, num y) {
    for (int i=pads.length - 1; i >= 0; i--) {
      LilyPad pad = pads[i];
      if (pad.overlapsPoint(x, y)) return pad;
    }
    return null;
  }
  
  
  void drawPond(CanvasRenderingContext2D ctx) {
    ctx.clearRect(0, 0, width, height);
    for (LilyPad pad in pads) {
      pad.draw(ctx);
    }
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
      Frog target = getFocalFrog(workspace.color);
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

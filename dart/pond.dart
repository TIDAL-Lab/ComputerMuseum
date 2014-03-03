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


class FrogPond extends TouchLayer {
  
  CanvasElement canvas;
  CanvasRenderingContext2D layer0;  // lily pads
  CanvasRenderingContext2D layer1;  // frogs
  CanvasRenderingContext2D layer2;  // bugs
  
  TouchManager tmanager = new TouchManager();
  
  List<CodeWorkspace> workspaces = new List<CodeWorkspace>();
  
  int width, height;
  
  /* List of bugs */
  AgentSet bugs = new AgentSet(null);
  
  /* List of frogs */
  AgentSet frogs;
  
  /* List of lilypads */
  AgentSet pads = new AgentSet(null);
  
  /* List of lattice grid points */
  List lattice = new List();
  
  /* Master timeout to restart exhibit after 80 seconds of inactivity */
  int _countdown = 0;

  
  FrogPond() {
    frogs = new AgentSet(this);
    
    canvas = querySelector("#pond");
    layer0 = canvas.getContext('2d');
    
    canvas = querySelector("#frogs");
    layer1 = canvas.getContext('2d');
    
    canvas = querySelector("#flies");
    layer2 = canvas.getContext('2d');
    
    width = canvas.width;
    height = canvas.height;
    
    tmanager.registerEvents(document.documentElement);
    tmanager.addTouchLayer(this);
    
    for (int i=0; i<MAX_BEETLES; i++) bugs.add(new Beetle(this));
    
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

    new Timer.periodic(const Duration(milliseconds : 40), tick);
    
    ImageElement lilypad = new ImageElement();
    lilypad.src = "images/lilypad.png";
    lilypad.onLoad.listen((e) {
      drawPond();
      workspaces.forEach((workspace) => workspace.draw());
      drawForeground();
    });
    
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
 * Adds a new frog for the given workspace
 */
  Frog addHomeFrog(CodeWorkspace workspace) {
    Frog frog = new Frog(this);
    frog["workspace"] = workspace.name;
    double fx = workspace.width / 2;
    double fy = workspace.height - 290.0;
    frog.x = workspace.objectToWorldX(fx, fy);
    frog.y = workspace.objectToWorldY(fx, fy);
    frog.heading = workspace.objectToWorldTheta(0);
    frog.program = new Program(workspace.start, frog);
    frog.img.src = "images/${workspace.color}frog.png";
    frogs.add(frog);
    return frog;
  }
  

/**
 * Count the number of frogs of a given color
 */
  int getFrogCount([String workspaceName = null]) {
    if (workspaceName == null) {
      return frogs.length;
    } else {
      return frogs.getCountWith((Turtle t) => t["workspace"] == workspaceName);
    }
  }
  

/**
 * Frog to trace program execution
 */
  Frog getFocalFrog(String workspace) {
    return frogs.getTurtleWith((Turtle t) => t["workspace"] == workspace);
  }
  
  
  void playProgram(CodeWorkspace workspace) {
    int count = getFrogCount(workspace.name);
    if (count == 0) addHomeFrog(workspace);
    for (Frog frog in frogs.agents) {
      if (frog["workspace"] == workspace.name) {
        frog.program.play();
      }
    }
  }
  
  
  void pauseProgram(CodeWorkspace workspace) {
    for (Frog frog in frogs.agents) {
      if (frog["workspace"] == workspace.name) {
        frog.program.pause();
      }
    }
  }
  
  
  void stopProgram(CodeWorkspace workspace) {
    for (Frog frog in frogs.agents) {
      if (frog["workspace"] == workspace.name) {
        frog.program.restart();
      }
    }
  }
  
  
  void restartProgram(CodeWorkspace workspace) {
    for (Frog frog in frogs.agents) {
      if (frog["workspace"] == workspace.name) {
        frog.die();
      }
    }
    addHomeFrog(workspace).pulse();
  }
  
  
/**
 * Are all programs paused?
 */
  bool isProgramPaused(String workspaceName) {
    for (Frog frog in frogs.agents) {
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
    for (Frog frog in frogs.agents) {
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
    for (Frog frog in frogs.agents) {
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
  }

  
/**
 * Capture a bug
 */
  void captureBug(Frog frog, Beetle bug) {
    // first find the workspace
    for (CodeWorkspace workspace in workspaces) {
      if (workspace.name == frog["workspace"]) {
        workspace.captureBug(bug);
        bugs.add(new Beetle(this));
      }
    }
  }
  
  
/**
 * Show a help message when a visitor touches a frog on the screen
 */
  void showHelpMessage(Frog frog) {
  }
  
  
/**
 * Animate and draw
 */
  void tick(Timer timer) {
    
    // remove dead frogs and bugs
    bugs.erase(layer2);
    bugs.removeDead();
    frogs.removeDead();
    
    bugs.animate();
    bugs.draw(layer2);
    
    // animate agents and workspaces
    bool refresh = false;

    if (frogs.animate()) refresh = true;

    for (CodeWorkspace workspace in workspaces) {    
      if (workspace.bug.animate()) refresh = true;
    }
    
    if (refresh) {
      drawForeground();
    }
    
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
 * Returns true if the given point is in the water
 */
  bool inWater(num x, num y) {
    return (pads.getTurtleAtPoint(x, y) == null);
  }
  
  
  bool onGridPoint(num x, num y, num r) {
    for (var point in lattice) {
      if (distance(x, y, point[0], point[1]) <= r) return true;
    }
    return false;
  }
  

  void drawPond() {
    layer0.clearRect(0, 0, width, height);
    pads.draw(layer0);
    drawGrid(layer0);
  }
  
  
  void drawGrid(CanvasRenderingContext2D ctx) {
    lattice.clear();
    double HSPACE = 150.0;
    double VSPACE = HSPACE * sin(PI / 3);
    ctx.save();
    ctx.globalAlpha = 0.05;
    ctx.fillStyle = 'white';
    ctx.strokeStyle = 'white';
    ctx.lineWidth = 4;
    
    double sx = 145.0;
    double sy = 20.0;
    
    for (int j=0; j<9; j++) {
      sx = (j % 2 == 0) ? 136.0 : 211.0;
      
      for (int i=0; i<12; i++) {
        if (!inWater(sx, sy)) {
          ctx.beginPath();
          ctx.arc(sx, sy, 10, 0, PI * 2, true);
          lattice.add([sx, sy]);
          //ctx.fill();

          ctx.beginPath();
          if (!inWater(sx + HSPACE, sy)) {
            ctx.moveTo(sx, sy);
            ctx.lineTo(sx + HSPACE, sy);
          }
          if (!inWater(sx + HSPACE/2, sy + VSPACE)) {
            ctx.moveTo(sx, sy);
            ctx.lineTo(sx + HSPACE/2, sy + VSPACE);
          }
          if (!inWater(sx - HSPACE/2, sy + VSPACE)) {
            ctx.moveTo(sx, sy);
            ctx.lineTo(sx - HSPACE/2, sy + VSPACE);
          }
          ctx.stroke();
        }
        sx += HSPACE;
      }
      sy += VSPACE;
    }
    ctx.restore();
  }
  
  
/**
 * Draws the bugs, frogs, and programming blocks
 */
  void drawForeground() {
    CanvasRenderingContext2D ctx = layer1;
    ctx.clearRect(0, 0, width, height);
    
    frogs.draw(ctx);
    
    for (CodeWorkspace workspace in workspaces) {
      Frog target = getFocalFrog(workspace.name);
      if (target != null) {
        workspace.traceExecution(ctx, target);
        workspace.drawBug(ctx);
      }
    }
  }
}

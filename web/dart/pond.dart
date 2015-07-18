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
  CanvasRenderingContext2D layer2;  // bugs
  
  TouchManager tmanager = new TouchManager();
  
  List<FrogWorkspace> workspaces = new List<FrogWorkspace>();
  
  int width, height;
  
  /* List of bugs */
  AgentSet<Beetle> bugs = new AgentSet<Beetle>();
  
  /* List of lilypads */
  AgentSet<LilyPad> pads = new AgentSet<LilyPad>();
  
  /* List of lattice grid points */
  List lattice = new List();
  
  /* Master timeout to restart exhibit after 80 seconds of inactivity */
  int _countdown = 0;

  
  FrogPond() {
    canvas = querySelector("#pond");
    layer0 = canvas.getContext('2d');
    
    canvas = querySelector("#flies");
    layer2 = canvas.getContext('2d');
    
    width = canvas.width;
    height = canvas.height;
    
    tmanager.registerEvents(document.documentElement);
    tmanager.addTouchLayer(this);
    
    for (int i=0; i<MAX_BEETLES; i++) bugs.add(new Beetle(this));
    
    addLilyPad(300.0, height/2, 0.65);
    addLilyPad(370.0, 110.0, 0.52);
    addLilyPad(545.0, 775.0, 0.8);
    addLilyPad(625.0, 345.0, 0.9);
    addLilyPad(910.0, height - 170.0, 0.65);
    addLilyPad(900.0, 630.0, 0.7);
    addLilyPad(1015.0, 240.0, 0.83);
    addLilyPad(1280.0, height - 130.0, 0.7);
    addLilyPad(1285.0, height/2 + 5, 0.8);
    addLilyPad(1370.0, 154.0, 0.6);
    addLilyPad(1595.0, height - 200, 0.52);
    addLilyPad(1620.0, height/2, 0.7);
    

    FrogWorkspace workspace = new FrogWorkspace(this, height, width, "yellow");
    workspace.transform(cos(PI / -2), sin(PI / -2), -sin(PI / -2), cos(PI / -2), 0, height);
    workspaces.add(workspace);
    tmanager.addTouchLayer(workspace);
    workspace.addHomeFrog();
  
    workspace = new FrogWorkspace(this, height, width, "red");
    workspace.transform(cos(PI/2), sin(PI/2), -sin(PI/2),cos(PI/2), width, 0);
    workspaces.add(workspace);
    tmanager.addTouchLayer(workspace);
    workspace.addHomeFrog();

    new Timer.periodic(const Duration(milliseconds : 30), tick);
    
    ImageElement lilypad = new ImageElement();
    lilypad.src = "images/lilypad.png";
    lilypad.onLoad.listen((e) {
      drawPond();
      workspaces.forEach((workspace) => workspace.draw());
    });
    
    //-----------------------------------------------------------------------------
    // master timeout
    //-----------------------------------------------------------------------------
    /*
    if (isFlagSet("timeout")) {
      print("initiating master restart timer");
      new Timer.periodic(const Duration(seconds : 10), (timer) {
        _countdown += 10;
        if (_countdown >= 80) window.location.reload();
      });
      document.documentElement.onMouseDown.listen((e) => _countdown = 0);
      document.documentElement.onTouchStart.listen((e) => _countdown = 0);
    }
    */
  }
  
  
  Frog getFrogHere(Turtle target) {
    for (FrogWorkspace workspace in workspaces) {
      Frog frog = workspace.frogs.getTurtleHere(target);
      if (frog != null) return frog;
    }
    return null;
  }
  
  
  bool isFrogHere(Turtle target) {
    return getFrogHere(target) != null;
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
 * Animate and draw
 */
  void tick(Timer timer) {
    
    // animate bugs
    bugs.erase(layer2);
    bugs.removeDead();
    bugs.animate();
    bugs.draw(layer2);
    
    // add a new bug if less than max
    if (bugs.length < MAX_BEETLES) {
      bugs.add(new Beetle(this));
    }
    
    // animate code workspaces
    for (FrogWorkspace workspace in workspaces) {
      if (workspace.animate()) workspace.draw();
    }
  }


/**
 * Spook all the bugs
 */  
  void spookBugs() {
    for (Beetle bug in bugs.agents) { 
      bug.spook(); 
      bug.forward(6);
    }
  }

  
/**
 * Returns true if the given point is in the water
 */
  bool inWater(num x, num y) {
    return (pads.getTurtleAtPoint(x, y) == null);
  }
  
  
  num getGridPoint(num x, num y, num r) {
    for (var point in lattice) {
      if (distance(x, y, point[0], point[1]) <= r) return point;
    }
    return null;
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
}  

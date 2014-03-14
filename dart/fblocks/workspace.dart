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


class CodeWorkspace extends TouchLayer {
  
  /* reference to the frog pond */
  FrogPond pond;
  
  /* size of the canvas */
  int width, height;
  
  /* list of frogs controlled by this workspace */
  AgentSet<Frog> frogs = new AgentSet<Frog>();

  /* list of blocks in the workspace */
  List<Block> blocks = new List<Block>();
  
  /* block menu */
  Menu menu;
  
  /* button toolbar */
  Toolbar toolbar;
  
  /* bug scoreboard */
  Scoreboard scoreboard;
  
  /* fixed start block */
  StartBlock start;
  
  /* name of this workspace */
  String name;
  
  /* color of the frogs controlled by this workspace */
  String color;
  
  /* traces execution of programs as they run */
  TraceBug bug;
  
  /* is the program currently running? */
  bool running = false;
  
  /* help message */
  Help help;
  
  CanvasElement canvas;
  
  CanvasRenderingContext2D ctx;

  

  
  CodeWorkspace(this.pond, this.width, this.height, this.name, this.color) {
    
    canvas = querySelector("#${name}");
    ctx = canvas.getContext('2d');

    frogs.tlayer = pond;
    
    // toolbar
    toolbar = new Toolbar(this, 0, height - BLOCK_HEIGHT * 1.85, 270, BLOCK_HEIGHT * 1.85);
    
    // menu bar
    menu = new Menu(this, 245, height - BLOCK_HEIGHT * 1.85, width - 245, BLOCK_HEIGHT * 1.85);
    _initMenu();
    
    // bug scoreboard
    scoreboard = new Scoreboard(this, width - 150, height - BLOCK_HEIGHT * 1.85, 150, BLOCK_HEIGHT * 1.85);
    
    // help message
    help = new Help(this);
    
    // start block
    start = new StartBlock(this);
    addBlock(start);
    buildDefaultProgram();
    
    // trace bug
    bug = new TraceBug(start);
    
    draw();
    
    help.show();
    
    // master timeout
    new Timer.periodic(const Duration(seconds : 5), doTimeout);
  }
  
  
/**
 * Master timeout function
 */
  void doTimeout(Timer t) {
    int time = getTimeSinceLastTouchEvent();
    if (time > 90) {
      resetTouchTimer();
      restartProgram();
      removeAllBlocks();
      buildDefaultProgram();
      scoreboard.reset();
      help.show();
    }
  }
  
  
/**
 * Adds a new frog for the given workspace
 */
  Frog addHomeFrog() {
    Frog frog = new Frog(pond, this);
    frog["workspace"] = name;
    double fx = width / 2;
    double fy = height - 290.0;
    frog.x = objectToWorldX(fx, fy);
    frog.y = objectToWorldY(fx, fy);
    frog.heading = objectToWorldTheta(0);
    frog.program = new Program(start, frog);
    frog.img.src = "images/${color}frog.png";
    frogs.add(frog);
    return frog;
  }
  
  
/**
 * Frog to trace program execution
 */
  Frog getFocalFrog() {
    return frogs.first;
  }
  
  
/**
 * Resume the program for all frogs
 */
  void playProgram() {
    if (frogs.length == 0) addHomeFrog();
    for (Frog frog in frogs.agents) {
      frog.program.play();
    }
  }

  
/**
 * Pause a running program for all frogs
 */
  void pauseProgram() {
    for (Frog frog in frogs.agents) {
      frog.program.pause();
    }
  }
  
  
/**
 * Halts all frogs and restarts their programs
 */
  void stopProgram() {
    for (Frog frog in frogs.agents) {
      frog.program.restart();
    }
  }

  
/**
 * Restart to single frog on home lilypad
 */
  void restartProgram() {
    for (Frog frog in frogs.agents) {
      frog.die();
    }
    addHomeFrog().pulse();
    bug.reset();
  }

  
/**
 * Is there a frog still running a program?
 */
  bool isProgramRunning() {
    bool running = false;
    for (Frog frog in frogs.agents) {
      if (frog.program.isRunning) running = true;
    }
    return running;
  }
  
  
/**
 * Erase a program
 */
  void removeAllBlocks() {
    stopProgram();
    Block block = start.next;
    while (block != null && block != start.end) {
      Block b = block.next;
      block.prev = null;
      block.next = null;
      removeBlock(block);
      block = b;
    }
    start.next = start.end;
    start.end.prev = start;
  }
  
    
/**
 * Creates a simple starting program so that there's something that can be run
 */
  void buildDefaultProgram() {
    Block block = new Block(this, 'hop');
    block.x = start.x;
    block.y = start.y - 300.0;
    addBlock(block);
    snapTogether(block);
    block.inserted = true;
  }
  
  
/**
 * Add a block to the workspace
 */
  void addBlock(Block block) {
    blocks.add(block);
    addTouchable(block);
    if (block.hasParam) addTouchable(block.param);
  }
  
  
/**
 * Remove a block from the workspace
 */
  void removeBlock(Block block) {
    blocks.remove(block);
    removeTouchable(block);
    if (block.hasParam) removeTouchable(block.param);
    draw();
  }
  
  
/**
 * Move a block to the top of the visual stack
 */
  void moveToTop(Block block) {
    removeBlock(block);
    addBlock(block);
  }
  
  
/**
 * How many blocks of the given type have been used in the program so far?
 */
  int getBlockCount(String blockType) {
    int count = 0;
    for (Block block in blocks) {
      if (block.type == blockType) count++;
    }
    return count;
  }
  
  
/**
 * Has a block been dragged off of the screen?
 */
  bool isOffscreen(Block block) {
    return (block.x + block.width > width ||
            block.x < 0 ||
            block.y + block.height > height ||
            block.y < 0);
  }
  
  
/**
 * Is a block over the menu?
 */
  bool isOverMenu(Block block) {
    return menu.overlaps(block);
  }
  

/**
 * Snap a block onto an existing program
 */
  bool snapTogether(Block target) {
    Block b = findInsertionPoint(target);
    if (b != null) {
      b.insertBlock(target);
      start.pulse();
      toolbar.pulsePlayButton();
      return true;
    } else {
      return false;
    }
  }
  
  
/**
 * Add a new block to the end of an existing program
 */
  void snapToEnd(Block target) {
    start.end.prev.insertBlock(target);
    start.pulse();
    toolbar.pulsePlayButton();
  }
  

/**
 * As a block is being dragged, determine the position after which the block
 * will be inserted into a program
 */
  Block findInsertionPoint(Block target) {
    Block block = start;
    Block result = null;
    while (block != null) {
      if (block.overlaps(target) && target.checkSyntax(block)) {
        result = block;
      }
      block = block.next;
    }
    if (result == null && !target.inserted) {
      return start.end.prev;
    } else if (target.y > start.end.y) {
      return null;
    } else {
      return result;
    }
  }
  
  
/**
 * Animate the blocks and return true if any of the blocks changed
 */
  bool animate() {
    bool refresh = false;
    
    frogs.removeDead();
    
    if (help.animate()) refresh = true;

    if (frogs.animate()) refresh = true;
    
    if (bug.animate()) refresh = true;
    
    if (frogs.length == 0) {
      restartProgram();
    }

    bool r = isProgramRunning();
    if (r != running) refresh = true;
    running = r;
    
    if (menu.animate()) refresh = true;
    
    if (toolbar.animate()) refresh = true;
    
    if (scoreboard.animate()) refresh = true;

    //----------------------------------------------
    // for each block being dragged, identify active insertion points 
    //----------------------------------------------
    for (Block block in blocks) block.candidate = null;
      
    for (Block target in blocks) {
      if (target.dragging) {
        Block b = findInsertionPoint(target);
        if (b != null) {
          b.candidate = target;
        }
      }
    }
      
    for (Block block in blocks) {
      if (block.animate()) refresh = true;
    }
    
    return refresh;
  }
  
  
/**
 * Called by pond to trace the execution of the program for the target frog
 */
  void traceExecution(Frog frog) {
    if (frog.label != null) {
      ctx.save();
      double tx = worldToObjectX(frog.x, frog.y);
      double ty = worldToObjectY(frog.x, frog.y);
      ctx.textBaseline = 'top';
      ctx.textAlign = 'center';
      ctx.fillStyle = 'white';
      ctx.font = '200 16px sans-serif';
      ctx.fillText(frog.label, tx, ty + 52);
      ctx.restore();
    }
    bug.target = frog.program.curr;
  }
  
  
  void captureBug(Beetle bug) {
    scoreboard.captureBug(bug);
  }  
  
  
  void draw() {
    ctx.save();
    {
      
      // erase the background
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      
      // draw the frogs
      frogs.draw(ctx);
      
      // transform into workspace coordinates
      xform.transformContext(ctx);
      
      Frog target = getFocalFrog();
      if (target != null) traceExecution(target);
      
      // draw blocks themselves
      for (Block block in blocks) {
        block.draw(ctx);
      }
      
      // draw the trace bug
      if (target != null) bug.draw(ctx);
      
      // draw the help message
      help.draw(ctx);
      
      // draw the menu and the toolbar
      ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
      ctx.fillRect(0, height - BLOCK_HEIGHT * 1.85, width, BLOCK_HEIGHT * 1.85);
      menu.draw(ctx);
      toolbar.draw(ctx);
      scoreboard.draw(ctx);
    }
    ctx.restore();
  }
  
  
  void showHideHelp() {
    help.showHide();
  }
  
  
  void _initMenu() {
    Block block;
    Parameter param;
    
    // HOP block
    menu.addBlock(new Block(this, 'hop'), 3);
    
    // CHIRP block
    menu.addBlock(new Block(this, 'chirp'), 2);
    
    // EAT block
    menu.addBlock(new Block(this, 'eat'), 2);
    
    // TURN block
    if (SHOW_TURN_BLOCK) {
      block = new Block(this, 'turn');
      block.param = new Parameter(block);
      block.param.values = [ -90, -75, -60, -45, -30, -15, 'random', 15, 30, 45, 60, 75, 90 ];
      block.param.index = 6;
      menu.addBlock(block, 2);
    }
    else {
      menu.addBlock(new Block(this, 'left'), 2);
      menu.addBlock(new Block(this, 'right'), 2);
    }
    
    menu.addBlock(new Block(this, 'spin'), 2);
    
    // HATCH block
    block = new Block(this, 'hatch');
    block.color = '#b67196';
    menu.addBlock(block, 1);
    
    // DIE block
    if (SHOW_DIE_BLOCK) {
      block = new Block(this, 'die');
      block.color = '#b67196';
      menu.addBlock(block, 1);
    }
    
    // IF block
    menu.addBlock(new IfBlock(this), 2);
    
    // REPEAT block
    menu.addBlock(new RepeatBlock(this), 2);
    
    // WAIT block
    if (SHOW_WAIT_BLOCK) menu.addBlock(new WaitBlock(this), 2);
        
  }
}
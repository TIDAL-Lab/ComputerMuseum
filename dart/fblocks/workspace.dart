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

  /* list of blocks in the workspace */
  List<Block> blocks = new List<Block>();
  
  /* block menu */
  Menu menu;
  
  /* button toolbar */
  Toolbar toolbar;
  
  /* status display (frog color, number of gems, number of flies) */
  StatusInfo status;
  
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
  
  CanvasRenderingContext2D ctx;

  

  
  CodeWorkspace(this.pond, this.width, this.height, this.name, this.color) {
    
    CanvasElement canvas = querySelector("#${name}");
    ctx = canvas.getContext('2d');

    // toolbar
    toolbar = new Toolbar(this, 0, height - BLOCK_HEIGHT * 1.85, 220, BLOCK_HEIGHT * 1.85);
    
    // menu bar
    menu = new Menu(this, 220, height - BLOCK_HEIGHT * 1.85, width - 220, BLOCK_HEIGHT * 1.85);
    _initMenu();
    
    // status area
    if (SHOW_STATUS) {
      status = new StatusInfo(this, width - 150, height - 100, 150, 100);
    }
    
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
  }
  
  
/**
 * Resume the program for all frogs
 */
  void playProgram() {
    pond.playProgram(this);
  }

  
/**
 * Pause a running program for all frogs
 */
  void pauseProgram() {
    pond.pauseProgram(this);
  }
  
  
/**
 * Halts all frogs and restarts their programs
 */
  void stopProgram() {
    pond.stopProgram(this);
  }

  
/**
 * Restart to single frog on home lilypad
 */
  void restartProgram() {
    pond.restartProgram(this);
    bug.reset();
  }
  
  
/**
 * Speeds up program execution
 */
  void fastForwardProgram() {
    pond.fastForwardProgram(this);
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
    
    buildDefaultProgram();    
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
 * Preview a block for all frogs
 */
  void preview(Block block) {
    if (SHOW_PREVIEW) {
      var pvalue = null;
      if (block.hasParam) pvalue = block.param.value;
      pond.pauseProgram(this);
      pond.previewBlock(name, block.text, pvalue);
    }
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
    
    if (help.animate()) {
      refresh = true;
    }

    bool r = pond.isProgramRunning(this.name);
    if (r != running) refresh = true;
    running = r;
    
    if (menu.animate()) refresh = true;
    if (toolbar.animate()) refresh = true;

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
    
    if (status != null && status.animate()) refresh = true;
    
    return refresh;
  }
  
  
/**
 * Called by pond to trace the execution of the program for the target frog
 */
  void traceExecution(CanvasRenderingContext2D ctx, Frog frog) {
    if (frog.label != null) {
      ctx.save();
      xform.transformContext(ctx);
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
  
  
  void drawBug(CanvasRenderingContext2D ctx) {
    ctx.save();
    {
      xform.transformContext(ctx);
      bug.draw(ctx);
    }
    ctx.restore();
  }
  
  
  void captureGem(Gem g) {
    if (status != null) status.captureGem(g);
  }
  
  
  void captureFly(Fly fly) {
    menu.captureFly(fly);
    if (status != null) {
      status.fly_count++;
      draw();
    }
  }  
  
  
  void draw() {
    ctx.save();
    {
      
      // transform into workspace coordinates
      xform.transformContext(ctx);
      
      // erase the background
      ctx.clearRect(0, 0, width, height);
      
      // draw the status bar
      if (status != null) status.draw(ctx);
  
      // draw blocks themselves
      for (Block block in blocks) {
        block.draw(ctx);
      }
      
      // draw the help message
      help.draw(ctx);
      
      // draw the menu and the toolbar
      menu.draw(ctx);
      toolbar.draw(ctx);
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
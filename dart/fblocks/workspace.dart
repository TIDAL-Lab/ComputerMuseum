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


class CodeWorkspace extends TouchManager {
  
  /* reference to the frog pond */
  FrogPond pond;
  
  /* size of the canvas */
  int width, height;

  /* list of blocks in the workspace */
  List<Block> blocks = new List<Block>();
  
  /* block menu */
  Menu menu;
  
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
  
  CanvasRenderingContext2D ctx;


  
  CodeWorkspace(this.pond, this.width, this.height, this.name, this.color) {
    
    CanvasElement canvas = document.query("#${name}");
    ctx = canvas.getContext('2d');

    registerEvents(document.documentElement);
    
    // menu bar
    menu = new Menu(this, 0, height - BLOCK_HEIGHT * 1.85, width, BLOCK_HEIGHT * 1.85);
    _initMenu();
    addTouchable(menu);
    
    // status area
    status = new StatusInfo(this, width - 220, height - 100, 220, 100);
    
    // start block
    start = new StartBlock(this);
    addBlock(start);
    
    // trace bug
    bug = new TraceBug(start);
    
    draw();
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
 * Preview a block for all frogs
 */
  void preview(Block block) {
    var pvalue = null;
    if (block.hasParam) pvalue = block.param.value;
    pond.pauseProgram(this);
    pond.previewBlock(name, block.text, pvalue);
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
  }
  
  
/**
 * Move a block to the top of the visual stack
 */
  void moveToTop(Block block) {
    removeBlock(block);
    addBlock(block);
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
    if (result == null && target.wasInMenu) {
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

    bool r = pond.isProgramRunning(this.name);
    if (r != running) refresh = true;
    running = r;

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
    
    if (status.animate()) refresh = true;
    
    if (bug.animate()) refresh = true;
    
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
  
  
  void draw() {
    ctx.save();
    {
      
      // transform into workspace coordinates
      xform.transformContext(ctx);
      
      // erase the background
      ctx.clearRect(0, 0, width, height);
      
      // draw the menu
      menu.draw(ctx);
      
      // draw the status bar
      status.draw(ctx);
  
      //------------------------------------------------
      // draw blocks themselves
      //------------------------------------------------
      for (Block block in blocks) {
        block.draw(ctx);
      }
      
      //------------------------------------------------
      // draw the trace bug
      //------------------------------------------------
      bug.draw(ctx);
    }
    ctx.restore();
  }
  
  
  void _initMenu() {
    Block block;
    Parameter param;
    
    // HOP block
    block = new Block(this, 'hop');
    block.param = new Parameter(block);
    block.param.values = [ 1, 2, 3, 4 ];
    menu.addBlock(block);
    
    // CHIRP block
    menu.addBlock(new Block(this, 'chirp'));
    
    // EAT block
    menu.addBlock(new Block(this, 'eat'));
    
    // TURN LEFT block
    block = new Block(this, 'left');
    block.param = new Parameter(block);
    block.param.values = [ 'random', 10, 20, 30, 40, 50, 60, 70, 80, 90 ];
    block.param.index = 3;
    menu.addBlock(block);
    
    // TURN RIGHT block
    block = new Block(this, 'right');
    block.param = new Parameter(block);
    block.param.values = [ 'random', 10, 20, 30, 40, 50, 60, 70, 80, 90 ];
    block.param.index = 3;
    menu.addBlock(block);
    
    // HATCH block
    block = new Block(this, 'hatch');
    block.color = '#b67196';
    menu.addBlock(block);
    
    // IF block
    menu.addBlock(new IfBlock(this));
    
    // REPEAT block
    menu.addBlock(new RepeatBlock(this));
    
    // WAIT block
    menu.addBlock(new WaitBlock(this));
        
  }
}
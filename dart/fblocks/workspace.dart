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


  
  CodeWorkspace(this.pond, this.name, this.color) {
    
    CanvasElement canvas = querySelector("#${name}");
    width = canvas.width;
    height = canvas.height;
    ctx = canvas.getContext('2d');

    // menu bar
    menu = new Menu(this, 0, height - BLOCK_HEIGHT * 1.85, width, BLOCK_HEIGHT * 1.85);
    _initMenu();
    addTouchable(menu);
    
    // start block
    start = new StartBlock(this);
    addBlock(start);
    
    // trace bug
    bug = new TraceBug(start);
    
    draw();
  }
  
  
/**
 * Restart to single frog on home lilypad
 */
// FIXME
/*  void restartProgram() {
    pond.restartProgram();
    bug.reset();
  }
*/  

  void stopProgram() {
    pond.stopProgram();
    bug.reset();
  }
  

/**
 * Erase a program
 */
/*
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
*/  
  
/**
 * Preview a block for all frogs
 */
  void preview(Block block) {
    var pvalue = null;
    if (block.hasParam) pvalue = block.param.value;
    pond.pauseProgram();
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

    bool r = pond.isProgramRunning();
    if (r != running) refresh = true;
    running = r;
    
    menu.animate();

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
      ctx.fillText("${frog.label}", tx, ty + 52);
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
  
  
  void draw() {
    ctx.save();
    {
      
      // transform into workspace coordinates
      xform.transformContext(ctx);
      
      // erase the background
      ctx.clearRect(0, 0, width, height);
      
      // draw the menu
      menu.draw(ctx);
      
      //------------------------------------------------
      // draw blocks themselves
      //------------------------------------------------
      for (Block block in blocks) {
        block.draw(ctx);
      }
    }
    ctx.restore();
  }
  
  
  void _initMenu() {
    Block block;
    Parameter param;
    
    // HOP block
    menu.addBlock(new Block(this, 'hop'));
    
    // CHIRP block
    menu.addBlock(new Block(this, 'chirp'));
    
    // EAT block
    menu.addBlock(new Block(this, 'eat'));
    
    // TURN block
    //block = new Block(this, 'turn');
    //block.param = new Parameter(block);
    //block.param.values = [ -90, -75, -60, -45, -30, -15, 'random', 15, 30, 45, 60, 75, 90 ];
    //block.param.index = 6;
    //menu.addBlock(block);
    
    menu.addBlock(new Block(this, 'left'));
    menu.addBlock(new Block(this, 'right'));
    
    
    // HATCH block
    block = new Block(this, 'hatch');
    block.color = '#b67196';
    menu.addBlock(block);
    
    // DIE block
    //block = new Block(this, 'die');
    //block.color = '#b67196';
    //menu.addBlock(block);
    
    // IF block
    menu.addBlock(new IfBlock(this));
    
    // REPEAT block
    //menu.addBlock(new RepeatBlock(this));
    
    // WAIT block
    menu.addBlock(new WaitBlock(this));
        
  }
}
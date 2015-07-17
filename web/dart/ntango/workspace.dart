/*
 * Computer History Museum Frog Pond
 * Copyright (c) 2014 Michael S. Horn
 * 
 *           Michael S. Horn (michael-horn@northwestern.edu)
 *           Northwestern University
 *           2120 Campus Drive
 *           Evanston, IL 60613
 *           http://tidal.northwestern.edu
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation.
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
part of NetTango;

abstract class CodeWorkspace extends TouchLayer {
  
  /* list of blocks in the workspace */
  List<Block> blocks = new List<Block>();
  
  /* size of the canvas */
  int width, height;
  
  /* block menu */
  Menu menu;
  
  /* fixed start block */
  StartBlock start;
  
  /* name of this workspace */
  String name;
  
  /* traces execution of programs as they run */
  TraceBug bug;
  
  /* button toolbar */
  Toolbar toolbar;
  
  /* help message */
  Help help;
  
  
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;

  
  CodeWorkspace(this.width, this.height, this.name) {
    
    canvas = querySelector("#${name}-workspace");
    ctx = canvas.getContext('2d');

    // toolbar
    toolbar = new Toolbar(this, 0, height - BLOCK_HEIGHT * 1.85, 270, BLOCK_HEIGHT * 1.85);
    
    // menu bar
    menu = new Menu(this, 245, height - BLOCK_HEIGHT * 1.85, width - 245, BLOCK_HEIGHT * 1.85);
    
    // start block
    start = new StartBlock(this);
    addBlock(start);
    buildDefaultProgram();
    
    // help message
    help = new Help(this);
    
    // trace bug
    bug = new TraceBug(start);
    
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
      help.show();
      Logging.logEvent("${name}-timeout");
    }
  }
  
  
  void traceProgram(Program program) {
    bug.target = program.curr;
  }


/**
 * Called when user moves a block on the screen
 */
  void programChanging();
  
  
/**
 * Called when the program structure changes
 */
  void programChanged();

  void playProgram();
  
  void pauseProgram();
  
  void restartProgram();
  
  bool isProgramRunning();
  

/**
 * Close all open parameter menus
 */  
  void closeAllParameterMenus() {
    for (Block block in blocks) {
      block.closeParameterMenu();
    }
    draw();
  }


/**
 * On a background touch, close all open parameter menus
 */
  bool backgroundTouch(Contact c) {
    transformContact(c);
    if (c.touchY > height - 900) {
      closeAllParameterMenus();
    }
    return false;
  }
  

/**
 * Erase a program
 */
  void removeAllBlocks() {
    programChanged();
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
  void buildDefaultProgram();
  
  
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
 * Is the program empty? Only a start block...
 */
  bool get isEmpty {
    return blocks.length <= 2;  // start and end blocks together
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
    
    if (bug.animate()) refresh = true;
    
    if (toolbar.animate()) refresh = true;
    
    if (menu.animate()) refresh = true;
    
    if (help.animate()) refresh = true;

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
      if (block.animate()) {
        refresh = true;
      }
    }
    
    return refresh;
  }
  
  
  void draw() {
    ctx.save();
    {
      // transform into workspace coordinates
      xform.transformContext(ctx);

      // draw the menu and toolbar
      ctx.fillStyle = '#0F3745'; //'rgba(0, 0, 0, 0.3)';
      ctx.fillRect(0, height - BLOCK_HEIGHT * 2, width, BLOCK_HEIGHT * 2);
      menu.draw(ctx);
      toolbar.draw(ctx);
      
      // draw blocks
      blocks.forEach((block) => block.draw(ctx));
      
      // draw the trace bug
      bug.draw(ctx);
      
      // draw the help message
      ctx.save();
      {
        ctx.rect(0, height - 500, width, 500 - BLOCK_HEIGHT * 2);
        ctx.clip();
        help.draw(ctx);
      }
      ctx.restore();
      
    }
    ctx.restore();
  }

  
  void showHideHelp() {
    help.showHide();
  }
  
  
  String toString() {
    String s = "[ START, ";
    Block b = start.next;
    while (b != null && !(b is EndProgramBlock)) {
      s += "${b.toString()}, ";
      b = b.next;
    }
    return s + "]";
  }
}
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


// TODO: Draw menu and status in the background layer!!

class CodeWorkspace extends TouchManager {
  
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
  
  FrogPond pond;
  
  
  CodeWorkspace(this.pond, this.width, this.height) {
    registerEvents(document.documentElement);
    
    addRandomFrog();
    
    menu = new Menu(this, 0, height - BLOCK_WIDTH * 1.5,
                    width, BLOCK_WIDTH * 1.5);
    
    status = new StatusInfo(this, width - 280, height - 115, 280, 115);
    
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
    block.param.values = [ 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 'random' ];
    block.param.index = 3;
    menu.addBlock(block);
    
    // TURN RIGHT block
    block = new Block(this, 'right');
    block.param = new Parameter(block);
    block.param.values = [ 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 'random' ];
    block.param.index = 3;
    menu.addBlock(block);
    
    // REST block
    //menu.addBlock(new Block(this, 'rest'));
    
    // HATCH block
    menu.addBlock(new Block(this, 'hatch'));
    
    // IF block
    menu.addBlock(new IfBlock(this));
    
    // REPEAT block
    menu.addBlock(new RepeatBlock(this));
    
    // WAIT block
    menu.addBlock(new WaitBlock(this));
        
    // START block
    start = new StartBlock(this, 75.0, height - 170.0);
    addBlock(start);
    
    addTouchable(menu);
  }
  
  
  void addRandomFrog() {
    for (int i=0; i<20; i++) {
      int x = Turtle.rand.nextInt(width - 200) + 100;
      int y = Turtle.rand.nextInt(height - 300) + 150;
      if (!pond.inWater(x, y)) {
        Frog frog = new Frog(pond, this);
        frog.x = x.toDouble();
        frog.y = y.toDouble();
        pond.addFrog(frog);
        return;
      }
    }
    // try again in 2 seconds
    new Timer(const Duration(milliseconds : 2000), addRandomFrog);
  }
  
  
  void addBlock(Block block) {
    blocks.add(block);
    addTouchable(block);
    if (block.hasParam) addTouchable(block.param);
  }
  
  
  void removeBlock(Block block) {
    blocks.remove(block);
    removeTouchable(block);
    if (block.hasParam) removeTouchable(block.param);
  }
  
  
  void moveToTop(Block block) {
    Block b = block;
    while (b != null) {
      removeBlock(b);
      addBlock(b);
      b = b.next;
    }
  }
  
  
/**
 * Are frogs still running their programs?
 */
  bool isProgramRunning() {
    for (Frog frog in pond.frogs) {
      if (frog.workspace == this) {
        if (frog.program != null && frog.program.isRunning) {
          return true;
        }
      }
    }
    return false;
  }
  
  
/**
 * Returns the number of frogs currently controlled by this workspace
 */
  int getFrogCount() {
    int count = 0;
    for (Frog frog in pond.frogs) {
      if (frog.workspace == this) count++;
    }
    return count;
  }
  
  
/**
 * Returns the target frog (that we show program execution for)
 */
  Frog getTargetFrog() {
    for (Frog frog in pond.frogs) {
      if (frog.workspace == this) return frog;
    }
    return null;
  }
  
  
/**
 * Resume the program for all frogs
 */
  void playProgram() {
    if (getFrogCount() == 0) {
      addRandomFrog();
    }
    for (Frog frog in pond.frogs) {
      if (frog.workspace == this) {
        if (frog.program == null) {
          frog.program = new Program(frog, start);
        } else if (frog.program.isFinished) {
          frog.program.restart();
        }
        frog.program.play();
      }
    }
  }
  
  
/**
 * Pause a running program for all frogs
 */
  void pauseProgram() {
    for (Frog frog in pond.frogs) {
      if (frog.workspace == this && frog.program != null) {
        frog.program.pause();
      }
    }
  }
  
  
/**
 * Restart the program for all frogs
 */
  void restartProgram() {
    for (Frog frog in pond.frogs) {
      if (frog.workspace == this && frog.program != null) {
        frog.program.restart();
      }
    }
  }
  
  
  void preview(Block block) {
    for (Frog frog in pond.frogs) {
      if (frog.workspace == this) {
        block.eval(frog, true);
      }
    }
  }
  
  
  bool isOffscreen(Block block) {
    return (block.x > width ||
            block.x < 0 ||
            block.y < 0 ||
            menu.overlaps(block));
  }
  
  
  bool isOverMenu(Block block) {
    return menu.overlaps(block);
  }
  
  
  bool snapTogether(Block target) {
    Block b = findInsertionPoint(target);
    if (b != null) {
      return b.snapTogether(target);
    } else {
      return false;
    }
  /*
    for (Block block in blocks) {
      if (block != target && !block.dragging) {
        if (block.snapTogether(target)) {
          return true;  
        }
      }
    }
    return false;
  */
  }
  
  
  bool isDragging() {
    for (Block block in blocks) {
      if (block.dragging) return true;
    }
    return false;
  }
  
  
  Block findInsertionPoint(Block target) {
    for (Block block in blocks) {
      if (block != target && !block.dragging) {
        if (block.overlapsConnector(target)) {
          
          if (block.connectorX < target.x && block.hasNext && block.next.hasNext && target.checkSyntax(block.next)) {
            return block.next;
          } else if (target.checkSyntax(block)) {
            return block;
          }
        }
      }
    }
    return null;
  }
  
  
  bool animate() {
    bool refresh = false;
    
    for (Block block in blocks) {
      if (block.isStartBlock) {
        if (block.animate())  refresh = true;
      }
    }
    return refresh;
  }
  
  
  bool captureGem(Gem gem) {
    if (!gem.dead) {
      status.captureGem(gem);
      new Timer(const Duration(milliseconds : 3000), () { pond.addGem(); });
      return true;
    }
    return false;
  }
  
  
  void captureFly(Fly fly) {
    if (!fly.dead) {
      fly.die();
      pond.addFly();
      status.fly_count++;
    }
  }
  
  
  void repaint() {
    pond.drawForeground();
  }
  
  
  void repaintBackground() {
    pond.drawBackground();
  }
  
  
  void drawBackground(CanvasRenderingContext2D ctx) {
    menu.draw(ctx);
    status.draw(ctx);
  }

  
  void draw(CanvasRenderingContext2D ctx) {
    
    //----------------------------------------------
    // for each block being dragged, identify active
    // insertion points and highlight them
    //----------------------------------------------
    for (Block block in blocks) {
      block.highlight = false;
    }
    
    for (Block target in blocks) {
      if (target.dragging) {
        Block b = findInsertionPoint(target);
        if (b != null) b.highlight = true;
      }
    }
    
    //------------------------------------------------
    // draw sockets
    //------------------------------------------------
    if (isDragging()) {
      for (Block block in blocks) {
        if (!block.dragging && block.isInProgram) {
          block.drawSockets(ctx);
        }
      }
    }
    
    //------------------------------------------------
    // draw connecting lines
    //------------------------------------------------
    for (Block block in blocks) {
      block.drawLines(ctx);
    }

    //------------------------------------------------
    // draw blocks
    //------------------------------------------------
    for (Block block in blocks) {
      block.draw(ctx);
    }
    
    //------------------------------------------------
    // draw parameters
    //------------------------------------------------
    for (Block block in blocks) {
      block.drawParams(ctx);
    }
    
    
    //------------------------------------------------
    // draw command label for the target frog
    //------------------------------------------------
    Frog target = getTargetFrog();
    if (target != null) {
      if (target.ghost != null && target.ghost.label != null) {
        target.ghost.drawLabel(ctx);
      } else {
        target.drawLabel(ctx);
      }
    }
  }
}

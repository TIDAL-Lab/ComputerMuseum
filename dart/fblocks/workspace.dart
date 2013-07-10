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
  
  /* canvas */
  CanvasElement canvas;

  /* list of frogs controlled by this workspace */  
  List<Turtle> frogs = new List<Frog>();
  
  /* list of blocks in the workspace */
  List<Block> blocks = new List<Block>();
  
  /* block menu */
  Menu menu;
  
  /* fixed start block */
  StartBlock start;
  
  FrogPond pond;
  
  
  CodeWorkspace(this.canvas, this.pond) {
    registerEvents(document.documentElement);
    //canvas.onSelectStart.listen((e) { e.preventDefault(); });
    
    Frog frog = new Frog();
    frog.x = canvas.width / 2;
    frog.y = 200.0;
    addFrog(frog);
    
    frog = new Frog();
    frog.x = canvas.width - 100.0;
    frog.y = 300.0;
    addFrog(frog);
    
    
    menu = new Menu(this, 0, canvas.height - BLOCK_WIDTH * 1.5,
                    canvas.width, BLOCK_WIDTH * 1.5);
    
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
    block.param.values = [ 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 'random' ];
    block.param.index = 3;
    menu.addBlock(block);
    
    // TURN RIGHT block
    block = new Block(this, 'right');
    block.param = new Parameter(block);
    block.param.values = [ 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 'random' ];
    block.param.index = 3;
    menu.addBlock(block);
    
    // REST block
    menu.addBlock(new Block(this, 'rest'));
    
    // HATCH block
    menu.addBlock(new Block(this, 'hatch'));
    
    // IF block
    menu.addBlock(new IfBlock(this));
    
    // REPEAT block
    menu.addBlock(new RepeatBlock(this));
    
    block = new RepeatBlock(this);
    block.text = 'repeat\nuntil';
    block.param.values = [ 'see-fly?', 'near-water?', 'hear-frog?' ];
    menu.addBlock(block);
    
    // WAIT block
    block = new Block(this, 'wait\nuntil');
    block.param = new Parameter(block);
    block.param.values = [ 'see-fly?', 'hear-frog?' ];
    block.color = '#c92';
    menu.addBlock(block);
        
    // START block
    start = new StartBlock(this, 55.0, canvas.height - 140.0);
    addBlock(start);
    
    addTouchable(menu);
  }
  
  
  void addFrog(Frog frog) {
    frogs.add(frog);
    addTouchable(frog);
  }
  
  
  void removeFrog(Frog frog) {
    frogs.remove(frog);
    removeTouchable(frog);
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
  
  
  void playProgram() {
    for (Frog frog in frogs) {
      frog.restore();
      frog.program = new Program(frog, start);
      frog.program.play();
    }
  }
  
  void pauseProgram() {
    for (Frog frog in frogs) {
      frog.program.pause();
    }
  }
  
  
  void restartProgram() {
    for (Frog frog in frogs) {
      frog.restore();
      if (frog.program != null) {
        frog.program.restart();
      }
    }
  }
  
  
  void preview(Block block) {
    for (Frog frog in frogs) {
      frog.save();
      block.eval(frog);
    }
  }
  
  
  void resetPreview() {
    for (Frog frog in frogs) {
      frog.restore();
    }
  }
  
  
  bool isOffscreen(Block block) {
    return (block.x > canvas.width ||
            block.x < 0 ||
            block.y < 0 ||
            menu.overlaps(block));
  }
  
  
  bool isOverMenu(Block block) {
    return menu.overlaps(block);
  }
  
  
  bool snapTogether(Block target) {
    for (Block block in blocks) {
      if (block != target && !block.dragging) {
        if (block.snapTogether(target)) {
          return true;  
        }
      }
    }
    return false;
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
        if (block.overlapsConnector(target) && target.checkSyntax(block)) {
          return block;
        }
      }
    }
    return null;
  }
  
  
  bool animate() {
    bool repaint = false;

    for (Block block in blocks) {
      if (block.isStartBlock) {
        if (block.animate())  repaint = true;
      }
    }
    
    for (Frog frog in frogs) {
      if (frog.animate()) repaint = true;
    }
    
    return repaint;
  }
  
  
  void repaint() {
    pond.draw();
  }

  
  void draw(CanvasRenderingContext2D ctx) {
    
    menu.draw(ctx);
    
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
    // draw frogs
    //------------------------------------------------
    for (Frog frog in frogs) {
      if (frog.saved != null) {
        ctx.globalAlpha = 0.3;
        frog.saved.draw(ctx);
        ctx.globalAlpha = 1.0;
      }
      frog.draw(ctx);
    }
    
    //if (frog.label != "hatch") {
    //  ctx.globalAlpha = 0.3;
    //}
    //ghost.draw(ctx);
    //ctx.globalAlpha = 1.0;
    //frog.draw(ctx);
  }
}

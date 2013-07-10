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

  
/**
 * Visual programming block
 */
class Menu implements Touchable {

  CodeWorkspace workspace;
  
  num x, y, w, h;
  
  List<Block> blocks = new List<Block>();
  
  Block target = null;
  
  
  
  Menu(this.workspace, this.x, this.y, this.w, this.h);
  
  
  void addBlock(Block block) {
    blocks.add(block);
  }
  
  
  bool overlaps(Block block) {
    return (block.y >= y && block.y <= y + h && block.x >= x && block.x <= x + w);
  }

  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save();
    {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
      ctx.fillRect(x, y, w, h);
      
      num bx = x + BLOCK_WIDTH * 0.75;
      num by = y + h / 2;
      num bs = BLOCK_WIDTH * 1.25;
      
      for (Block block in blocks) {
        block.x = bx;
        block.y = by;
        block.draw(ctx);
        bx += bs;
      }
    }
    ctx.restore();
  }
  
  
  bool containsTouch(Contact c) {
    for (Block block in blocks) {
      if (block.containsTouch(c)) {
        return true;
      }
    }
    return false;
  }
  
  
  bool touchDown(Contact c) {
    for (Block block in blocks) {
      if (block.containsTouch(c)) {
        target = block.clone();
        workspace.addBlock(target);
        target.move(-2, -8);
        target.touchDown(c);
        return true;
      }
    }
    return false;
  }
  
  
  void touchUp(Contact c) {
    if (target != null) {
      target.touchUp(c);
    }
    target = null;
  }
  
  
  void touchDrag(Contact c) {
    if (target != null) {
      target.touchDrag(c);
    }
  }
  
  
  void touchSlide(Contact c) {
  }
}

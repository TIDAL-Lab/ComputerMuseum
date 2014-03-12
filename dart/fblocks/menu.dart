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

  
/**
 * Visual programming menu bar
 */
class Menu {

  /* Link back to the code workspace that owns this menu bar */
  CodeWorkspace workspace;
  
  /* Dimensions of the menu */
  num x, y, w, h;
  
  /* Slots for programming blocks */
  List<Slot> slots = new List<Slot>();
  
  
  Menu(this.workspace, this.x, this.y, this.w, this.h);
  
  
  void addBlock(Block block, int count) {
    slots.add(new Slot(block, workspace, count));
  }
  
  
  bool overlaps(Block block) {
    return (block.centerY >= y);
  }
  
  
  bool animate() {
    return false;
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save();
    {
      num ix = x + 25;
      num iy = y + h/2;
      
      for (Slot slot in slots) {
        slot.x = ix;
        slot.y = iy - slot.height / 2;
        slot.draw(ctx);
        ix += slot.width + 10;
      }
    }
    ctx.restore();
  }
}

  
class Slot implements Touchable {
  
  Block block;
  Block target = null;
  num x, y;
  
  CodeWorkspace workspace;
  
  int count = 2;
  
  
  Slot(this.block, this.workspace, this.count) {
    block.inMenu = true;
    workspace.addTouchable(this);
  }
  
  
  bool isAvailable() {
    return workspace.getBlockCount(block.type) < count;
  }
  
  
  num get width => block.width;
  num get height => block.height;
  
  
  void draw(CanvasRenderingContext2D ctx) {
    int free = count - workspace.getBlockCount(block.type);
    if (free <= 0) {
      block.x = x.toDouble() - 4;
      block.y = y.toDouble() + 4;
      block.draw(ctx, true);
    } else {
      for (int i=0; i<free; i++) {
        block.x = x.toDouble() + (i - 1) * 4;
        block.y = y.toDouble() - (i - 1) * 4;
        block.draw(ctx);
      }
    }
  }
  
  
  bool containsTouch(Contact c) {
    return block.containsTouch(c);
  }
  
  
  bool touchDown(Contact c) {
    if (target == null && block.containsTouch(c) && isAvailable()) {
      target = block.clone();
      workspace.addBlock(target);
      target.move(-2, -8);
      target.touchDown(c);
      return true;
    } else {
      return false;
    }
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
  
  void touchSlide(Contact c) { }
}

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
  
  /* List of the blocks in the menu bar */
  List<Slot> slots = new List<Slot>();
  
  /* Beetle scoreboard */
  Map<String, Beetle> beetles = new Map<String, Beetle>();
  
  
  Menu(this.workspace, this.x, this.y, this.w, this.h) {
    // scoreboard
    int bx = x + w - 30;
    for (String color in Beetle.colors) {
      Beetle b = new Beetle(workspace.pond, color);
      beetles[color] = b;
      b.x = bx.toDouble();
      b.y = y + h/2;
      b.heading = 0.0;
      b.perched = true;
      b.locked = true;
      b.shadowed = true;
      bx -= 40;
    }
  }
  
  
  void addBlock(Block block, int count) {
    slots.add(new Slot(block, workspace, count));
  }
  
  
  bool overlaps(Block block) {
    return (block.centerY >= y);
  }
  
  void captureFly(Fly fly) {
    if (fly is Beetle) {
      beetles[fly.color].shadowed = false;
      beetles[fly.color].pulse();
    }
  }
  
  
  bool animate() {
    bool refresh = false;
    for (Beetle beetle in beetles.values) {
      if (beetle.animate()) refresh = true;
    }
    return refresh;
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save();
    {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
      ctx.fillRect(x, y, w, h);

      //---------------------------------------------
      // programming blocks
      //---------------------------------------------
      int ix = x + 25;
      int iy = y + h/2;
      
      for (Slot slot in slots) {
        slot.x = ix;
        slot.y = iy - slot.height / 2;
        slot.draw(ctx);
        ix += slot.width + 10;
      }
      
      //---------------------------------------------
      // scoreboard
      //---------------------------------------------
      for (String color in beetles.keys) {
        beetles[color].draw(ctx);
      }
    }
    ctx.restore();
  }
} 


class Slot implements Touchable {
  
  Block block;
  Block target = null;
  
  CodeWorkspace workspace;
  
  int count = 2;
  
  
  Slot(this.block, this.workspace, this.count) {
    block.inMenu = true;
    workspace.addTouchable(this);
  }
  
  
  bool isAvailable() {
    return workspace.getBlockCount(block.type) < count;
  }
  
  
  set x(num value) => block.x = value;
  set y(num value) => block.y = value;
  num get width => block.width;
  num get height => block.height;
  
  
  void draw(CanvasRenderingContext2D ctx) {
    block.draw(ctx, ! isAvailable());
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

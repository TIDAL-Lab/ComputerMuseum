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
 * Start block
 */
class StartBlock extends Block {
  
  EndProgramBlock end;
  
  
  StartBlock(CodeWorkspace workspace, double x, double y) : super(workspace, '') {
    this.x = x;
    this.y = y;
    color = 'green';
    end = new EndProgramBlock(workspace, x, y);
    end.prev = this;
    next = end;
    workspace.addBlock(end);
  }

  
  bool get isStartBlock => true;

  
  bool overlapsConnector(Block target) {
    if (next == end) {
      return true;
    } else {
      return super.overlapsConnector(target);
    }
  }

  
  bool snapTogether(Block target) {
    if (super.overlapsConnector(target)) {
      return super.snapTogether(target);
    } else {
      return false;
    }
  }

  
  bool animate() {
    if (hasNext) {
      return next.animate();
    } else {
      return false;
    }
  }
  
  /**
   * Draw the block
   */
  void draw(CanvasRenderingContext2D ctx) {
    ctx.restore();
    ctx.fillStyle = 'white';
    super.draw(ctx);
    ctx.beginPath();
    int delta = dragging ? 2 : 0;
    if (workspace.isProgramRunning()) {
      ctx.moveTo(x - 5 + delta, y - 9 + delta);
      ctx.lineTo(x - 5 + delta, y + 9 + delta);
      ctx.moveTo(x + 5 + delta, y - 9 + delta);
      ctx.lineTo(x + 5 + delta, y + 9 + delta);
    } else {
      ctx.moveTo(x + 6 + delta, y + delta);
      ctx.lineTo(x - 4 + delta, y - 5 + delta);
      ctx.lineTo(x - 4 + delta, y + 5 + delta);
      ctx.closePath();
    }
    ctx.fill();
    ctx.lineWidth = 6;
    ctx.lineJoin = 'miter';
    ctx.lineCap = 'butt';
    ctx.strokeStyle = 'white';
    ctx.stroke();
  }

  
  bool containsTouch(Contact c) {
    return distance(c.touchX, c.touchY, x, y) <= width ~/ 2;
  }
  

  bool touchDown(Contact c) {
    deltaX = c.touchX - x;
    deltaY = c.touchY - y;
    lastX = x;
    lastY = y;
    dragging = true;
    workspace.moveToTop(this);
    workspace.repaint();
    return true;
  }
  
  
  void touchUp(Contact c) {
    dragging = false;
    if (workspace.isProgramRunning()) {
      workspace.pauseProgram();
    } else {
      workspace.playProgram();
    }
    workspace.repaint();
  }
  
  
  void touchDrag(Contact c) {
    moveChain((c.touchX - deltaX) - lastX, (c.touchY - deltaY) - lastY);
    lastX = x;
    lastY = y;
    workspace.repaint();
  }
}




/**
* Visual programming block
*/
class EndProgramBlock extends Block {

  
  EndProgramBlock(CodeWorkspace workspace, double x, double y) : super(workspace, 'end') {
    this.x = x;
    this.y = y;
    color = '#a00';
  }
  
  
  Block step(Frog frog) {
    return this;
  }

  
  bool overlapsConnector(Block target) {
    return false;
  }
  
  
  void drawLines(CanvasRenderingContext2D ctx) {
    /*
    ctx.save();
    {
      ctx.strokeStyle = 'white';
      ctx.fillStyle = 'white';
      drawLineArrow(ctx, prev.x, y, x - BLOCK_WIDTH * 0.4, y, LINE_WIDTH);
    }
    ctx.restore();
    */
  }
  
  void draw(CanvasRenderingContext2D ctx) {
    super.draw(ctx);
    ctx.save();
    {
      ctx.strokeStyle = 'white';
      ctx.fillStyle = 'white';
      drawLineArrow(ctx, prev.x + prev.width / 2, y, x - BLOCK_WIDTH * 0.4, y, LINE_WIDTH);
    }
    ctx.restore();
  }
  
  
  bool touchDown(Contact c) {
    return false;
  }
}

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


/**
 * Superclass for all control blocks (e.g. if, repeat, wait)
 */
class ControlBlock extends Block {


  /* Reference to the first block of the control structure */  
  BeginBlock begin = null;
  
  /* Next clause in a control structure (e.g. else if, else, end repeat) */
  ControlBlock cnext = null;
  
  /* Previous clause in a control structure (e.g. else if, if, repeat) */
  ControlBlock cprev = null;
  
  
  ControlBlock(CodeWorkspace workspace, BeginBlock begin, String text) : super(workspace, text) {
    color = '#c92';  // yellow-orange color
    this.begin = begin;
  }

  
  num get targetX {
    if (!dragging && cprev != null && cprev.isInProgram) {
      return super.targetX - BLOCK_MARGIN;
    } else {
      return super.targetX;
    }
  }
  
  
  num get targetY {
    if (candidate == null && cnext != null && cnext == next) {
      return super.targetY - 25;
    } else {
      return super.targetY;
    }
  }

  
  num get connectorX {
    if (cnext != null) {
      return targetX + BLOCK_MARGIN;
    } else {
      return targetX;
    }
  }
  
  
  bool animate() {
    bool locked = false;
    ControlBlock c = begin;
    while (c != null) {
      if (c.dragging) locked = true;
      c = c.cnext;
    }
    if (locked) {
      return true;
    } else {
      return super.animate();
    }
  }
 
  
  void draw(CanvasRenderingContext2D ctx, [ bool disabled = false ]) {
    _resize(ctx);
    /*
    _drawMenuArrow(ctx);
    _drawLabel(ctx, begin.x + 12, centerY);
    _drawParam(ctx);
    */
  }  
  
  
/**
 * Make sure blocks are properly nested
 */
  bool checkSyntax(Block before) {
    
    // if there's a previous clause, make sure it's before this block
    if (inserted && cprev != null) {
      int nest = 0;
      Block p = before;
      while (true) {
        if (p == null) {
          return false;
        } else if (p == cprev) {
          if (nest != 0) {
            return false;
          } else {
            break;
          }
        } else if (p is EndBlock) {
          nest--;
        } else if (p is BeginBlock) {
          nest++;
        }
        p = p.prev;
      }
    }
    
    // if there's a next clause, make sure it's after this block
    if (inserted && cnext != null) {
      int nest = 0;
      Block a = before.next;
      while (true) {
        if (a == null) {
          return false;
        } else if (a == cnext) {
          if (nest != 0) {
            return false;
          } else {
            break;
          }
        } else if (a is EndBlock) {
          nest--;
        } else if (a is BeginBlock) {
          nest++;
        }
        a = a.next;
      }
    }

    return true;
  }
  
  
  void touchUp(Contact c) {
    bool wasInProgram = inserted;
    
    bool broken = false;
    
    if (begin != null && begin.prev != null) {
      broken = x > begin.prev.x + begin.prev.width;
    }
    
    super.touchUp(c);
    if (broken) {
      begin.removeAllBlocks();
    } else if (inserted && !wasInProgram) {
      begin.addAllBlocks();
    } else if (!isInProgram) {
      begin.removeAllBlocks();
      workspace.draw();
    }
  }
  
  
  void touchCancel(Contact c) {
    touchUp(c);
  }

  
  bool touchDown(Contact c) {
    //if (cnext != null && next == cnext && cprev != null && prev == cprev) return false;
    super.touchDown(c);
    // move all connected control blocks to the top
    if (inserted) {
      ControlBlock b = begin;
      while (b != null) {
        workspace.moveToTop(b);
        b = b.cnext;
      }
    }
    return true;
  }
  
  
  void touchDrag(Contact c) {
    if (!inserted) {
      super.touchDrag(c);
      return;
    }
    
    double tx = c.touchX;
    double ty = c.touchY;
    double dy = ty - _lastY;
    
    double miny = (cprev != null) ? cprev.y + cprev.height - 1 : 0;
    double maxy = (cnext != null) ? cnext.y - height : workspace.start.end.y - height;
    double newy = max(miny, min(maxy, y + dy)); 
    
    x += (tx - _lastX);
    y = newy;
    
    if (begin != this) begin.x = x;
    
    _lastX = tx;
    _lastY = ty; 
  }
}


/**
 * First block in a control chain
 */
class BeginBlock extends ControlBlock {
  
  /* Every control squence in a program must have an end block */
  EndBlock end;
  
  BeginBlock(CodeWorkspace workspace, String text) : super(workspace, null, text) {
    begin = this;
  }
  

  void draw(CanvasRenderingContext2D ctx, [ bool disabled = false ]) {
    ctx.globalAlpha = disabled ? 0.3 : 1.0;
    _resize(ctx);
    _drawMenuArrow(ctx);
    _drawOutline(ctx);
    _drawLabel(ctx, x + 12, centerY);
    _drawParam(ctx);
    ctx.globalAlpha = 1.0;
    ControlBlock cn = cnext;
    if (!inMenu && inserted) {
      while (cn != null) {
        cn._drawLabel(ctx, x + 12, cn.centerY);
        cn = cn.cnext;
      }
    }
  }
  
  
  void _addClause(ControlBlock clause) {
    ControlBlock c = this;
    while (c != null) {
      if (c.cnext == null) {
        c.cnext = clause;
        c.next = clause;
        clause.cprev = c;
        clause.prev = c;
        return;
      } else {
        c = c.cnext;
      }
    }
  }
  
  
  Block _endStep(Program program) {
    return end.next;
  }


  void _subpath(CanvasRenderingContext2D ctx, ControlBlock b) {
    num x0 = x;
    num x1 = x0 + b.width;
    num y0 = b.y;
    num y1 = b.y + b.height;
    num n = 20 + BLOCK_MARGIN;
    if (b is BeginBlock) n -= BLOCK_MARGIN;
    if (!(b is StartBlock)) {
      ctx.lineTo(x0 + n, y0);
      ctx.lineTo(x0 + n + 5, y0 + 4);
      ctx.lineTo(x0 + n + 10, y0 + 4);
      ctx.lineTo(x0 + n + 15, y0);
    }
    ctx.lineTo(x1, y0);
    ctx.lineTo(x1, y1);
    if (b is BeginBlock) {
      n += BLOCK_MARGIN;
    } else if (b is EndBlock) {
      n -= BLOCK_MARGIN;
    }
    if (!(b is EndProgramBlock)) {
      ctx.lineTo(x0 + n + 15, y1);
      ctx.lineTo(x0 + n + 10, y1 + 4);
      ctx.lineTo(x0 + n + 5, y1 + 4);
      ctx.lineTo(x0 + n, y1);
    }
    if (b.cnext != null) {
      num y2 = b.cnext.y;
      if (y2 > y1 + 20) {
        ctx.lineTo(x0 + BLOCK_MARGIN + 14, y1);
        ctx.quadraticCurveTo(x0 + BLOCK_MARGIN, y1, x0 + BLOCK_MARGIN, y1 + 14);
        ctx.lineTo(x0 + BLOCK_MARGIN, y2 - 14);
        ctx.quadraticCurveTo(x0 + BLOCK_MARGIN, y2, x0 + BLOCK_MARGIN + 14, y2);
      } else {
        ctx.lineTo(x0 + BLOCK_MARGIN, y1);
        ctx.lineTo(x0 + BLOCK_MARGIN, y2);
        ctx.lineTo(x0 + BLOCK_MARGIN + 14, y2);
      }
    }    
  }
  
  
  void _outline(CanvasRenderingContext2D ctx, num x, num y, num w, num h) {
    if (!inserted) {
      super._outline(ctx, x, y, w, h);
    } else {
      
      num r0 = (prev == null || prev is BeginBlock) ? 14 : 2;
      num r1 = (next == null || end.next is EndBlock || end.next == null) ? 14 : 2;
      
      num y0 = y;
      num y3 = end.y + end.height;

      ctx.beginPath();
      ctx.moveTo(x + r0, y0);
      ControlBlock clause = this;
      while (clause != null) {
        _subpath(ctx, clause);
        clause = clause.cnext;
      }
      ctx.lineTo(x + r1, y3);
      ctx.quadraticCurveTo(x, y3, x, y3 - r1);
      ctx.lineTo(x, y0 + r0);
      ctx.quadraticCurveTo(x, y0, x + r0, y0);
      ctx.closePath();
    }
  }
  
  
  void addAllBlocks() {
    next.prev = end;
    end.next = next;
    next = cnext;
    cnext.prev = this;
    ControlBlock b = cnext;
    while (b != null) {
      b.x = x;
      b.y = y + height;
      workspace.addBlock(b);
      b.inserted = true;
      b = b.cnext;
    }
  }
  
  
  void removeAllBlocks() {
    ControlBlock b = this;
    while (b != null) {
      if (b.hasPrev) b.prev.next = b.next;
      if (b.hasNext) b.next.prev = b.prev;
      b.prev = null;
      b.next = null;
      workspace.removeBlock(b);
      b = b.cnext;
    }
  }
}


class EndBlock extends ControlBlock {
  
  EndBlock(CodeWorkspace workspace, BeginBlock begin) : super(workspace, begin, '') {
    _height = BLOCK_MARGIN * 1.8;
  }
  
  
  Block step(Program program) {
    if (begin != null) {
      return begin._endStep(program);
    } else {
      return next;
    }
  }
  
  
  String toString() {
    return "end";
  }

  
  String compile(int indent) {
    String tab = "";
    for (int i=0; i<indent-1; i++) tab += "  ";
    return tab + "}\n";
  }
}

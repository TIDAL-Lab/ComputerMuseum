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
  
  
  num get targetY {
    if (_targetY != null) return _targetY;
    num ty = hasNext ? next.targetY - height - BLOCK_SPACE : y;
    if (candidate != null) {
      ty -= (max(candidate.height, 25) + BLOCK_SPACE);
    }
    if (candidate == null && cnext != null && cnext == next) {
      ty -= 25;
    }
    return ty;
  }
  
  
  void draw(CanvasRenderingContext2D ctx) { }

  
/**
 * Make sure blocks are properly nested
 */
  bool checkSyntax(Block before) {
    
    // if there's a previous clause, make sure it's before this block
    if (cprev != null) {
      Block p = before;
      while (p != cprev) {
        if (p == null) {
          return false;
        } else {
          p = p.prev;
        }
      }
    }
    
    // if there's a next clause, make sure it's after this block
    if (cnext != null) {
      Block a = before.next;
      while (a != cnext) {
        if (a == null) {
          return false;
        } else {
          a = a.next;
        }
      }
    }

    // make sure block is properly nested    
    Block after = before.next;
    int nest = 0;
    
    while (after != null) {
      if (after == cnext) {
        return (nest == 0);
      } else if (after is EndBlock) {
        nest--;
      } else if (after is BeginBlock) {
        nest++;
      }
      after = after.next;
    }
    return false;
  }
  
  
  bool touchDown(Contact c) {
    super.touchDown(c);
    if (inserted && begin != null) workspace.moveToTop(begin);
    return true;
  }
  
  
  void touchDrag(Contact c) {
    if (!inserted) {
      super.touchDrag(c);
      return;
    }
    double miny = (cprev != null) ? cprev.y + cprev.height + 25 : 0;
    double maxy = (cnext != null) ? cnext.y - height - 25 : workspace.start.end.y - height;
    
    double ty = y + (c.touchY - _lastY);
    double dx = (this is BeginBlock) ? (c.touchX - _lastX) : 0.0;
    
    if (ty < miny) {
      move(dx, (miny - y));
      _lastX = c.touchX;
      _lastY = y;
    } else if (ty > maxy) {
      move(dx, (maxy - y));
      _lastX = c.touchX;
      _lastY = y;
    } else {
      move(dx, c.touchY - _lastY);
      _lastX = c.touchX;
      _lastY = c.touchY;
    }
  }
}


/**
 * First block in a control chain
 */
class BeginBlock extends ControlBlock {
  
  /* Every control squence in a program must have an end block */
  EndBlock end;
  
  BeginBlock(CodeWorkspace workspace, String text) : super(workspace, null, text);
  
  num get connectorX => targetX + BLOCK_MARGIN;
  
  
  void draw(CanvasRenderingContext2D ctx) {
    _resize(ctx);
    _drawMenuArrow(ctx);
    _drawOutline(ctx);
    _drawLabel(ctx);
    _drawParam(ctx);
    if (inserted) {
      ControlBlock b = cnext;
      while (b != null) {
        b.x = x;
        b._resize(ctx);
        b._drawLabel(ctx);
        b._drawParam(ctx);
        b.x += BLOCK_MARGIN;
        b = b.cnext;
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
      ctx.lineTo(x0 + BLOCK_MARGIN + 14, y1);
      ctx.quadraticCurveTo(x0 + BLOCK_MARGIN, y1, x0 + BLOCK_MARGIN, y1 + 14);
      ctx.lineTo(x0 + BLOCK_MARGIN, y2 - 14);
      ctx.quadraticCurveTo(x0 + BLOCK_MARGIN, y2, x0 + BLOCK_MARGIN + 14, y2);
    }    
  }
  
  
  void _outline(CanvasRenderingContext2D ctx, num x, num y, num w, num h) {
    if (!inserted) {
      super._outline(ctx, x, y, w, h);
    } else {
      
      num r0 = (prev == null || prev is BeginBlock) ? 14 : 2;
      num r1 = (next == null || end.next is EndBlock || end.next == null) ? 14 : 2;
      num r2 = 2;
      num n = 20;
      
      num y0 = y;
      num y1 = y + h;
      num y2 = max(end.y, y1 + 16);
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
  
  
  void touchUp(Contact c) {
    bool wasInProgram = inserted;
    super.touchUp(c);
    if (inserted && !wasInProgram) {
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
    else if (!isInProgram) {
      ControlBlock b = this;
      while (b != null) {
        if (b.hasPrev) b.prev.next = b.next;
        if (b.hasNext) b.next.prev = b.prev;
        b.prev = null;
        b.next = null;
        workspace.removeBlock(b);
        b = b.cnext;
      }
      cnext = null;
      workspace.draw();
    }
  }
}


class EndBlock extends ControlBlock {
  
  EndBlock(CodeWorkspace workspace, BeginBlock begin) : super(workspace, begin, '') {
    _height = BLOCK_MARGIN * 1.8;
  }
  
  
  num get connectorX => (begin.isInProgram) ? targetX - BLOCK_MARGIN : targetX;

  
  Block step(Program program) {
    if (begin != null) {
      return begin._endStep(program);
    } else {
      return next;
    }
  }

  
  void eval(Program program) {
    var pval = (param == null) ? null : param.value;
    program.doCommand("end ${begin.text}", pval);
  }
  
  
  String compile(int indent) {
    String tab = "";
    for (int i=0; i<indent - 1; i++) tab += "  ";
    return "${tab}}\n";
  }

  
  void draw(CanvasRenderingContext2D ctx) { }

  
  bool checkSyntax(Block before) {
    if (before is EndProgramBlock) return false;
    int nest = 0;
    while (before != null) {
      if (before == begin) {
        return (nest == 0);
      } else if (before is EndBlock) {
        nest++;
      } else if (before is BeginBlock) {
        nest--;
      }
      before = before.prev;
    }
    return false;
  }  

}

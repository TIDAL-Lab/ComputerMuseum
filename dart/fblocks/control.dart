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

  
class BeginBlock extends Block {
  
  EndBlock end = null;

  
  BeginBlock(CodeWorkspace workspace, String text) : super(workspace, text) {
    color = '#c92';
  }
  
  
  Block _endStep(Program program) {
    return end.next;
  }
  
  
  num get connectorX {
    if (BLOCK_ORIENTATION == VERTICAL) {
      return targetX + BLOCK_MARGIN;
    } else {
      return super.connectorX;
    }
  }
  
  
  num get targetY {
    if (_targetY != null) return _targetY;
    if (BLOCK_ORIENTATION == VERTICAL) {
      num ty = hasNext ? next.targetY - height - BLOCK_SPACE : y;
      if (candidate != null) {
        ty -= candidate.height + BLOCK_SPACE;
      }
      //if (end != null && next == end) {
      //  ty -= 30;
      //}
      return ty;
    }
    return super.targetY;
  }  

  
/**
 * Make sure blocks are properly nested
 */
  bool checkSyntax(Block before) {

    int nest = 0;
    if (end == null) return true;
    Block after = before.next;
    
    while (after != null) {
      if (after == end) {
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
  
  
  bool overlaps(Block other) {
    if (end != null && end == next) {
      return (x <= other.x + other.width + BLOCK_SPACE &&
              other.x <= x + width + BLOCK_SPACE &&
              y <= other.y + other.height + BLOCK_SPACE &&
              other.y <= end.y + BLOCK_SPACE);
    } else {
      return super.overlaps(other);
    }
  }
  
  
  void _outline(CanvasRenderingContext2D ctx, num x, num y, num w, num h) {
    if (end != null && !dragging) {
      
      num r0 = (prev == null || prev is BeginBlock) ? 14 : 2;
      num r1 = (next == null || end.next is EndBlock || end.next == null) ? 14 : 2;
      num r2 = 2;
      num n = 20;
      num endy = end.y + end.height - end._height;
      //if (dragging) {
      //  y = min(y, end.y - height - BLOCK_SPACE - 30);
      //}
      ctx.beginPath();
      ctx.moveTo(x + r0, y);
      if (!(this is StartBlock)) {
        ctx.lineTo(x + n, y);
        ctx.lineTo(x + n + 5, y + 4);
        ctx.lineTo(x + n + 10, y + 4);
        ctx.lineTo(x + n + 15, y);
      }
      ctx.lineTo(x + w - r2, y);
      ctx.quadraticCurveTo(x + w, y, x + w, y + r2);
      ctx.lineTo(x + w, y + h - r2);
      ctx.quadraticCurveTo(x + w, y + h, x + w - r2, y + h);
      n += BLOCK_MARGIN;
      ctx.lineTo(x + n + 15, y + h);
      ctx.lineTo(x + n + 10, y + h + 4);
      ctx.lineTo(x + n + 5, y + h + 4);
      ctx.lineTo(x + n, y + h);
      ctx.lineTo(x + BLOCK_MARGIN + 14, y + h);
      ctx.quadraticCurveTo(x + BLOCK_MARGIN, y + h, x + BLOCK_MARGIN, y + h + 14);
      ctx.lineTo(x + BLOCK_MARGIN, endy - 14);
      ctx.quadraticCurveTo(x + BLOCK_MARGIN, endy, x + BLOCK_MARGIN + 14, endy);
      ctx.lineTo(x + n, endy);
      ctx.lineTo(x + n + 5, endy + 4);
      ctx.lineTo(x + n + 10, endy + 4);
      ctx.lineTo(x + n + 15, endy);
      ctx.lineTo(x + end.width, endy);
      ctx.lineTo(x + end.width, end.y + end.height);
      n -= BLOCK_MARGIN;
      if (!(this is StartBlock)) {
        ctx.lineTo(x + n + 15, end.y + end.height);
        ctx.lineTo(x + n + 10, end.y + end.height + 4);
        ctx.lineTo(x + n + 5, end.y + end.height + 4);
        ctx.lineTo(x + n, end.y + end.height);
      }
      ctx.lineTo(x + r1, end.y + end.height);
      ctx.quadraticCurveTo(x, end.y + end.height, x, end.y + end.height - r1);
      ctx.lineTo(x, y + r0);
      ctx.quadraticCurveTo(x, y, x + r0, y);
      ctx.closePath();
    } else {
      super._outline(ctx, x, y, w, h);
    }
  }

  
  void touchUp(Contact c) {
    super.touchUp(c);
    if (end == null && isInProgram) {
      end = new EndBlock(workspace, this);
      if (hasNext) {
        next.prev = end;
        end.next = next;
      }
      next = end;
      end.prev = this;
      workspace.addBlock(end);
    }
    else if (end != null && !isInProgram) {
      end.next.prev = end.prev;
      end.prev.next = end.next;
      end.prev = null;
      end.next = null;
      workspace.removeBlock(end);
      end = null;
    }
  }
}


class EndBlock extends Block {
  
  BeginBlock begin = null;
  
  
  EndBlock(CodeWorkspace workspace, BeginBlock begin) : super(workspace, '') {
    this.begin = begin;
    color = '#c92';
    x = begin.x;
    y = begin.y + BLOCK_MARGIN;
    _height = BLOCK_MARGIN * 1.5;
  }
  
  
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
  
  
  num get height => (prev == begin) ? _height * 3 : _height;
  
  
  num get connectorX {
    if (BLOCK_ORIENTATION == VERTICAL && begin != null && !begin.dragging) {
      return targetX - BLOCK_MARGIN;
    } else {
      return super.connectorX;
    }
  }

  
  String compile(int indent) {
    String tab = "";
    for (int i=0; i<indent - 1; i++) tab += "  ";
    return "${tab}}\n";
  }

  
  void draw(CanvasRenderingContext2D ctx) {
    return;
  }
  
  void drawShadow(CanvasRenderingContext2D ctx) {
    return;
  }
  
  
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
  
  
  bool touchDown(Contact c) {
    return false;
  }
}

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

class RepeatBlock extends BeginBlock {
  
  
  RepeatBlock(CodeWorkspace workspace) : super(workspace, 'repeat') {
    color = '#c92';
    param = new Parameter(this);
    param.centerX = width - 7;
    param.values = [ 2, 3, 4, 5, 'forever', 'near-water?', 'see-gem?' ];
  }
  
  
  num get connectorX {
    if (BLOCK_ORIENTATION == VERTICAL) {
      return targetX + BLOCK_MARGIN;
    } else {
      return super.connectorX;
    }
  }
  
  
  num get targetY {
    if (BLOCK_ORIENTATION == VERTICAL && end != null && next == end && candidate == null) {
      return next.targetY - height - BLOCK_SPACE - 30;
    } else {
      return super.targetY;
    }
  }
  
  
  Block clone() {
    RepeatBlock block = new RepeatBlock(workspace);
    copyTo(block);
    return block;
  }
  
  
  void parameterChanged(Parameter param) {
    if (param.value == "near-water?" || param.value == "see-gem?") {
      text = "repeat\nuntil";
    } else {
      text = "repeat";
    }
  }

  
  String compile(int indent) {
    String tab = "";
    for (int i=0; i<indent; i++) tab += "  ";
    return "${tab}repeat (${param.value}) {\n";
  }
    
  
  Block step(Program program) {
    String v = "repeat-counter-${id}";
    if (!program.hasVariable(v) || param.changed) {
      program[v] = param.value;
      param.changed = false;
    }
    
    var p = program[v];
    
    // counting loop
    if (p is int) {
      if (p <= 0) {
        program.removeVariable(v);
        return end.next;
      } else {
        program[v] = p - 1;
        return next;
      }
    }
    
    // infinite loop
    else if (p == "forever") {
      return next;
    }
    
    // conditional loops
    // TODO!!
    /*
    else if (param.value == "near-water?") {
      return frog.nearWater() ? end.next : next;
    }
    
    else if (param.value == "see-gem?") {
      return frog.seeGem() ? end.next : next;
    }
    */
    else {
      return next;
    }
  }

  
  void _outline(CanvasRenderingContext2D ctx, num x, num y, num w, num h) {
    if (end != null && !dragging) {
      
      num r0 = hasPrev ? 2 : 14;
      num r1 = hasPrev ? 2 : 14;
      num r2 = 2;
      num n = 20;
      //if (dragging) {
      //  y = min(y, end.y - height - BLOCK_SPACE - 30);
      //}
      ctx.beginPath();
      ctx.moveTo(x + r0, y);
      ctx.lineTo(x + n, y);
      ctx.lineTo(x + n + 5, y + 4);
      ctx.lineTo(x + n + 10, y + 4);
      ctx.lineTo(x + n + 15, y);
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
      ctx.lineTo(x + BLOCK_MARGIN, end.y - 14);
      ctx.quadraticCurveTo(x + BLOCK_MARGIN, end.y, x + BLOCK_MARGIN + 14, end.y);
      ctx.lineTo(x + n, end.y);
      ctx.lineTo(x + n + 5, end.y + 4);
      ctx.lineTo(x + n + 10, end.y + 4);
      ctx.lineTo(x + n + 15, end.y);
      ctx.lineTo(x + BLOCK_WIDTH, end.y);
      ctx.lineTo(x + BLOCK_WIDTH, end.y + end.height);
      n -= BLOCK_MARGIN;
      ctx.lineTo(x + n + 15, end.y + end.height);
      ctx.lineTo(x + n + 10, end.y + end.height + 4);
      ctx.lineTo(x + n + 5, end.y + end.height + 4);
      ctx.lineTo(x + n, end.y + end.height);
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
      end = new EndRepeat(workspace, x, y);
      end.begin = this;
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


class EndRepeat extends EndBlock {
  
  
  EndRepeat(CodeWorkspace workspace, double x, double y) : super(workspace, '') {
    color = '#eb0';
    color = '#c92';
    this.x = x;
    this.y = y;
    _height = BLOCK_MARGIN * 1.5;
  }

  
  num get connectorX {
    if (BLOCK_ORIENTATION == VERTICAL && begin != null && !begin.dragging) {
      return targetX - BLOCK_MARGIN;
    } else {
      return super.connectorX;
    }
  }
  
  
  Block step(Program program) {
    return begin;
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

  
  bool touchDown(Contact c) {
    return false;
  }
  
}

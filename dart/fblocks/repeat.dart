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
    param.values = [ 'forever', 1, 2, 3, 4, 5, 'near-water?', 'see-gem?' ];
    param.align = 'center';
    _width = BLOCK_WIDTH + 10;
  }

  
  Block clone() {
    RepeatBlock block = new RepeatBlock(workspace);
    copyTo(block);
    return block;
  }
  
  //num get targetY => hasPrev ? prev.connectorY - BLOCK_MARGIN : y;
  
  num get connectorY => targetY - BLOCK_MARGIN;
  
  num get connectorX {
    if (next == end && candidate == null) {
      return targetX + width + BLOCK_SPACE + BLOCK_WIDTH / 2;
    } else {
      return targetX + width + BLOCK_SPACE;
    }
  }
  
  
  void parameterChanged(Parameter param) {
    if (param.value == "near-water?" || param.value == "see-gem?") {
      text = "repeat until";
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
    if (end != null) {
      
      num x0 = min(x, end.x - w);
      num x1 = x0 + w;
      num x2 = end.x;
      num x3 = end.x + end.width;
      
      num y0 = (dragging) ? end.y : y;
      num y1 = (end.dragging) ? y : end.y;
      num y2 = y1 + end.height - BLOCK_MARGIN; //end.getBottomLine() - BLOCK_MARGIN;
      num y3 = y1 + end.height; //end.getBottomLine();
      //y3 = max(y3, y + h + BLOCK_MARGIN);
      
      ctx.beginPath();
      ctx.moveTo(x0, y0);
      /*
      ctx.lineTo(x0, y0 + h/2 - 8);
      ctx.lineTo(x0 + 6, y0 + h/2 - 2);
      ctx.lineTo(x0 + 6, y0 + h/2 + 2);
      ctx.lineTo(x0, y0 + h/2 + 8);
      */
      ctx.lineTo(x0, y3);
      ctx.lineTo(x3, y3);
      /*
      ctx.lineTo(x3, y1 + h/2 + 8);
      ctx.lineTo(x3 + 6, y1 + h/2 + 2);
      ctx.lineTo(x3 + 6, y1 + h/2 - 2);
      ctx.lineTo(x3, y1 + h/2 - 8);
      */
      ctx.lineTo(x3, y1);
      ctx.lineTo(x2, y1);
      /*
      ctx.lineTo(x2, y1 + h/2 - 8);
      ctx.lineTo(x2 + 6, y1 + h/2 - 2);
      ctx.lineTo(x2 + 6, y1 + h/2 + 2);
      ctx.lineTo(x2, y1 + h/2 + 8);
      */
      ctx.lineTo(x2, y2);
      ctx.lineTo(x1, y2);
      /*
      ctx.lineTo(x1, y0 + h/2 + 8);
      ctx.lineTo(x1 + 6, y0 + h/2 + 2);
      ctx.lineTo(x1 + 6, y0 + h/2 - 2);
      ctx.lineTo(x1, y0 + h/2 - 8);
      */
      ctx.lineTo(x1, y0);
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
    _width = BLOCK_MARGIN * 2;
  }
  
  //num get connectorY => targetY + BLOCK_MARGIN;
  
  num get targetY => hasPrev ? prev.connectorY + BLOCK_MARGIN : y;
  
  
  Block step(Program program) {
    return begin;
  }
  
  
  String compile(int indent) {
    String tab = "";
    for (int i=0; i<indent - 1; i++) tab += "  ";
    return "${tab}}\n";
  }

  
  void drawShadow(CanvasRenderingContext2D ctx) {
    return;
  }
  
  void draw(CanvasRenderingContext2D ctx) {
    if (begin != null && begin.dragging) {
      super.draw(ctx);
    }
  }
  
  bool touchDown(Contact c) {
    workspace.moveToTop(begin);
    return super.touchDown(c);
  }
  
}

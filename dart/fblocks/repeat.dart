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
    param.values = [ 'forever', 1, 2, 3, 4, 5 ];
  }

  
  Block clone() {
    RepeatBlock block = new RepeatBlock(workspace);
    block.x = x;
    block.y = y;
    block.text = text;
    block.param.values = param.values;
    return block;
  }
  
  
  void eval(Frog frog, [bool preview = false]) {
    String v = "repeat-counter-${id}";
    if (!frog.hasVariable(v) || param.changed) {
      frog.doRepeat("repeat ${param.value}", param);
    } else {
      frog.doRepeat("repeat ${frog[v]}", param);
    }
  }
  
  
  Block step(Frog frog) {
    String v = "repeat-counter-${id}";
    if (!frog.hasVariable(v) || param.changed) {
      frog[v] = param.value;
      param.changed = false;
    }
    
    var p = frog[v];
    
    // counting loop
    if (p is int) {
      if (p <= 0) {
        frog.removeVariable(v);
        return end.next;
      } else {
        frog[v] = p - 1;
        return next;
      }
    }
    
    // infinite loop
    else if (p == "forever") {
      return next;
    }
    
    // conditional loops
    else if (param.value == "near-water?") {
      return frog.nearWater() ? end.next : next;
    }
    
    else if (param.value == "see-gem?") {
      return frog.seeGem() ? end.next : next;
    }
  }
  
  
  void drawLines(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = 'white';
    ctx.strokeStyle = 'white';
    ctx.lineWidth = LINE_WIDTH;
    ctx.lineCap = 'round';
    if (end != null) {
      double y0 = end.getTopLine();
      ctx.beginPath();
      ctx.moveTo(end.x, y0);
      ctx.lineTo(x, y0);
      ctx.stroke();
    }
    super.drawLines(ctx);
  }

  
  void draw(CanvasRenderingContext2D ctx) {
    super.draw(ctx);
    if (end != null) {
      ctx.save();
      ctx.fillStyle = 'white';
      ctx.strokeStyle = 'white';
      double y0 = end.getTopLine();
      double gap = height * 0.6;
      if (y0 > y + height / 2) {
        drawLineArrow(ctx, x, y0, x, y + gap, LINE_WIDTH);
      } else if (y0 < y - height / 2) {
        drawLineArrow(ctx, x, y0, x, y - gap, LINE_WIDTH);
      }
      ctx.restore();
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
  
  
  EndRepeat(CodeWorkspace workspace, double x, double y) : super(workspace, 'end\nrepeat') {
    color = '#eb0';
    color = '#c92';
    this.x = x;
    this.y = y;
  }
  
  
  Block step(Frog frog) {
    return begin;
  }
  
  
  void drawLines(CanvasRenderingContext2D ctx) {
    double y1 = getTopLine();
    ctx.save();
    {
      ctx.strokeStyle = 'white';
      ctx.fillStyle = 'white';
      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';
      ctx.lineWidth = LINE_WIDTH;
      ctx.beginPath();
      ctx.moveTo(x, y);
      ctx.lineTo(x, y1);
      ctx.stroke();
    }
    ctx.restore();
    super.drawLines(ctx);
  }
  
  
  Block clone() {
    return new EndRepeat(workspace, x, y);
  }
  
  
  void touchUp(Contact c) {
    super.touchUp(c);
    if (!isInProgram) {
      begin.next.prev = begin.prev;
      begin.prev.next = begin.next;
      begin.prev = null;
      begin.next = null;
      workspace.removeBlock(begin);
      begin = null;
    }
  }
}

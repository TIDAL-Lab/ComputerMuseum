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

  
class IfBlock extends BeginBlock {
  

  IfBlock(CodeWorkspace workspace) : super(workspace, 'if') {
    color = '#c92';
    param = new Parameter(this);
    param.values = [ 'see-fly?', 'near-water?', 'random?' ];
  }
  
  
  Block clone() {
    IfBlock block = new IfBlock(workspace);
    block.x = x;
    block.y = y;
    return block;
  }
  
  
  void drawLines(CanvasRenderingContext2D ctx) {
    if (end != null) {
      ctx.save();
      ctx.fillStyle = 'white';
      ctx.strokeStyle = 'white';
      ctx.lineWidth = LINE_WIDTH;
      ctx.lineCap = 'round';
      double y0 = end.getTopLine();
      ctx.beginPath();
      ctx.moveTo(end.x, y0);
      ctx.lineTo(x, y0);
      ctx.stroke();
      ctx.restore();
    }
  }
  

  void draw(CanvasRenderingContext2D ctx) {
    super.draw(ctx);
      
    if (end != null) {
      ctx.save();
      ctx.fillStyle = 'white';
      ctx.strokeStyle = 'white';
      double y0 = end.getTopLine();
      double gap = height * 0.5;
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
      end = new EndIf(workspace, x, y);
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


class EndIf extends EndBlock {
  
  
  EndIf(CodeWorkspace workspace, double x, double y) : super(workspace, 'end if') {
    color = '#c92';
    this.x = x;
    this.y = y;
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
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
      //ctx.lineTo(begin.x, y1);
      ctx.stroke();
    }
    ctx.restore();
    super.draw(ctx);
  }

  
  Block clone() {
    return new EndIf(workspace, x, y);
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

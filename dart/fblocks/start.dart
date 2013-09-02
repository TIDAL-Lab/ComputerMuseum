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
class StartBlock extends BeginBlock {
  
  double _pulse = 1.0;
  
  Tween tween = new Tween();
  
  
  
  StartBlock(CodeWorkspace workspace, double x, double y) : super(workspace, 'start') {
    this.x = x;
    this.y = y;
    color = 'green';
    end = new EndProgramBlock(workspace, this);
    end.y = y + height + BLOCK_MARGIN + 20;
    end.prev = this;
    next = end;
    workspace.addBlock(end);
    _width = BLOCK_WIDTH + BLOCK_MARGIN;
  }
  
  
  void pulse() {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 5;
    tween.duration = 30;
    tween.repeat = 3;
    tween.onstart = (() => _pulse = 1.0 );
    tween.onend = (() => _pulse = 1.0 );
    tween.ondelta = ((value) {
      _pulse += value;
    });
    tween.addControlPoint(1.0, 0.0);
    tween.addControlPoint(0.0, 0.5);
    tween.addControlPoint(1.0, 1.0);
  }
  
  
  bool animate() {
    bool refresh = super.animate();
    if (tween.isTweening()) {
      tween.animate();
      return true;
    } else {
      return refresh;
    }
  }

  
  bool get isInProgram => true;

  /**
   * Draw the block
   */
  void draw(CanvasRenderingContext2D ctx) {
    super.draw(ctx);
    ctx.beginPath();
    int delta = dragging ? 2 : 0;
    double cx = centerX + delta;
    double cy = centerY + delta;
    if (workspace.isProgramRunning()) {
      _pauseShape(ctx, cx, cy);
    } else {
      _playShape(ctx, cx, cy);
    }
    ctx.save();
    {
      double alpha = _pulse;
      ctx.shadowOffsetX = 1;
      ctx.shadowOffsetY = 1;
      ctx.shadowBlur = 3;
      ctx.shadowColor = "rgba(0, 0, 0, 0.3)";

      ctx.fillStyle = "rgba(255, 255, 255, ${alpha})";
      ctx.fill(); 
    }
    ctx.restore();
  }
  
  
  void _playShape(CanvasRenderingContext2D ctx, num cx, num cy) {
    ctx.beginPath();
    ctx.moveTo(cx + 12, cy);
    ctx.lineTo(cx - 8, cy - 10);
    ctx.lineTo(cx - 8, cy + 10);
    ctx.closePath();
  }
  
  
  void _pauseShape(CanvasRenderingContext2D ctx, num cx, num cy) {
    ctx.beginPath();
    ctx.moveTo(cx - 8, cy - 9);
    ctx.lineTo(cx - 8, cy + 9);
    ctx.lineTo(cx - 2, cy + 9);
    ctx.lineTo(cx - 2, cy - 9);
    ctx.closePath();
    ctx.moveTo(cx + 8, cy - 9);
    ctx.lineTo(cx + 8, cy + 9);
    ctx.lineTo(cx + 2, cy + 9);
    ctx.lineTo(cx + 2, cy - 9);
    ctx.closePath();
  }
  
  
  bool touchDown(Contact c) {
    dragging = false;
    _lastX = c.touchX;
    _lastY = c.touchY;
    workspace.draw();
    workspace.playProgram();
    return true;
  }
  
  
  void touchDrag(Contact c) {
    moveChain(c.touchX - _lastX, c.touchY - _lastY);
    _lastX = c.touchX;
    _lastY = c.touchY;
    workspace.draw();
  }
  
  
  void touchUp(Contact c) {
    dragging = false;
    workspace.draw();
  }
}




/**
* Visual programming block
*/
class EndProgramBlock extends EndBlock {
    //color = '#a00';

  
  EndProgramBlock(CodeWorkspace workspace, StartBlock begin) : super(workspace, begin) {
    _width = BLOCK_WIDTH + BLOCK_MARGIN;
  }
  

  Block step(Program program) {
    return this;
  }
}

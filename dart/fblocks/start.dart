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
  
  double _pulse = 1.0;
  
  Tween tween = new Tween();
  
  
  StartBlock(CodeWorkspace workspace, double x, double y) : super(workspace, '') {
    this.x = x;
    this.y = y;
    color = 'green';
    end = new EndProgramBlock(workspace, x, y);
    end.prev = this;
    next = end;
    workspace.addBlock(end);
  }
  
  
  void pulse() {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 5;
    tween.duration = 8;
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
    dragging = true;
    _lastX = c.touchX;
    _lastY = c.touchY;
    workspace.moveToTop(this);
    workspace.draw();
    workspace.playProgram();
    return true;
  }
  
  
  void touchUp(Contact c) {
    dragging = false;
    workspace.draw();
  }
  
  
  void touchDrag(Contact c) {
    //moveChain(c.touchX - _lastX, c.touchY - _lastY);
    _lastX = c.touchX;
    _lastY = c.touchY;
    workspace.draw();
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
  

  /*
  Block step(Frog frog) {
    return this;
  }
*/
/*  
  void draw(CanvasRenderingContext2D ctx) {
    super.draw(ctx);
    ctx.save();
    {
      ctx.strokeStyle = 'white';
      ctx.fillStyle = 'white';
      drawLineArrow(ctx, centerX - width / 2, centerY,
                    centerX - BLOCK_WIDTH * 0.4, centerY, LINE_WIDTH);
    }
    ctx.restore();
  }
*/  
  
  bool touchDown(Contact c) {
    return false;
  }
}

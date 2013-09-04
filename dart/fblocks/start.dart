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
  
  bool pdown = false, rdown = false;
  
  bool playing = false;
  
  Tween tween = new Tween();
  
  ImageElement _play = new ImageElement();
  ImageElement _pause = new ImageElement();
  ImageElement _restart = new ImageElement();
  
  
  
  StartBlock(CodeWorkspace workspace) : super(workspace, '') {
    x = getStartX();
    y = getStartY();
    color = 'green';
    end = new EndProgramBlock(workspace, this);
    end.y = y + height + BLOCK_MARGIN + 20;
    end.prev = this;
    next = end;
    workspace.addBlock(end);
    _width = BLOCK_WIDTH + BLOCK_MARGIN;
    _play.src = "images/play.png";
    _pause.src = "images/pause.png";
    _restart.src = "images/restart.png";
    wasInMenu = false;
  }
  
  
  double getProgramHeight() {
    return (end.y + end.height) - y;
  }
  
  
  double getStartX() {
    return workspace.width / 2 - 300.0;
  }
  
  
  double getStartY() {
    return workspace.height - 180.0;
  }
  
  
  void pulse() {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 5;
    tween.duration = 20;
    tween.repeat = 2;
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
    if (playing) {
      _drawPause(ctx);
    } else {
      _drawPlay(ctx);
    }
    _drawRestart(ctx);
  }
  
  
  void _drawPause(CanvasRenderingContext2D ctx) {
    num ix = x + 35;
    num iy = y + height/2;
    num iw = _pause.width;
    num ih = _pause.height;
    if (pdown && onPlayPauseButton(_lastX, _lastY)) {
      ix += 2;
      iy += 2;
    }
    ctx.drawImage(_pause, ix - iw/2, iy - ih/2);
  }
  
  
  void _drawPlay(CanvasRenderingContext2D ctx) {
    num ix = x + 35;
    num iy = y + height/2;
    num iw = _play.width;
    num ih = _play.height;
    if (pdown && onPlayPauseButton(_lastX, _lastY)) {
      ix += 2;
      iy += 2;
    }
    ctx.save();
    ctx.globalAlpha  = _pulse;
    ctx.drawImage(_play, ix - iw/2, iy - ih/2);
    ctx.restore();
  }
  
  
  void _drawRestart(CanvasRenderingContext2D ctx) {
    num ix = x + 70;
    num iy = y + height/2;
    num iw = _restart.width;
    num ih = _restart.height;
    if (rdown && onRestartButton(_lastX, _lastY)) {
      ix += 2;
      iy += 2;
    }
    ctx.drawImage(_restart, ix - iw/2, iy - ih/2);
  }
  
  
  bool isOutOfBounds() {
    return (y < getStartY() - getProgramHeight() - 100.0 ||
            y + getProgramHeight() > workspace.height ||
            x < 0 || x + width > workspace.width);
  }
  
  
  bool touchDown(Contact c) {
    dragging = false;
    pdown = false;
    rdown = false;
    if (onPlayPauseButton(c.touchX, c.touchY)) {
      pdown = true;
    } else if (onRestartButton(c.touchX, c.touchY)) {
      rdown = true;
    } 
    _lastX = c.touchX;
    _lastY = c.touchY;
    workspace.draw();
    return true;
  }
  
  
  void touchDrag(Contact c) {
    if (!pdown && !rdown) {
      moveChain(c.touchX - _lastX, c.touchY - _lastY);
    }
    _lastX = c.touchX;
    _lastY = c.touchY;
    workspace.draw();
  }
  
  
  void touchUp(Contact c) {
    dragging = false;
    if (pdown && onPlayPauseButton(c.touchX, c.touchY)) {
      if (playing) {
        workspace.pauseProgram();
      } else {
        workspace.playProgram();
      }
    }
    else if (rdown && onRestartButton(c.touchX, c.touchY)) {
      workspace.restartProgram();
    }
    else if (isOutOfBounds()) {
      _targetX = getStartX();
      end._targetY = getStartY() + height;
    }
    pdown = false;
    rdown = false;
    workspace.draw();
  }
  
  
  bool onPlayPauseButton(double tx, double ty) {
    return (tx >= x + 23 && tx <= x + 47 && ty >= y && ty <= y + height);
  }
  
  
  bool onRestartButton(double tx, double ty) {
    return (tx >= x + 58 && tx <= x + width && ty >= y && ty <= y + height);
  }
}



/**
* Visual programming block
*/
class EndProgramBlock extends EndBlock {
    //color = '#a00';

  
  EndProgramBlock(CodeWorkspace workspace, StartBlock begin) : super(workspace, begin) {
    _width = BLOCK_WIDTH + BLOCK_MARGIN;
    wasInMenu = false;
  }
}

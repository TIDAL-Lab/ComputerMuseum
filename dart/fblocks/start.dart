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
  
  Button _play, _pause, _target = null;
  
  
  StartBlock(CodeWorkspace workspace) : super(workspace, 'start') {
    x = getStartX();
    y = getStartY();
    color = 'green';
    end = new EndProgramBlock(workspace, this);
    end.y = y + height + BLOCK_MARGIN + 20;
    end.prev = this;
    next = end;
    workspace.addBlock(end);
    wasInMenu = false;
    _width = BLOCK_WIDTH + BLOCK_MARGIN;
    _play = new Button(x + 65, y + height / 2 - 15, "images/toolbar/play.png", () {
      workspace.playProgram(); });
    _pause = new Button(x + 65, y + height / 2 - 15, "images/toolbar/pause.png", () {
      workspace.pauseProgram(); });
    _pause.visible = false;
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
  
  
  bool animate() {
    bool refresh = super.animate();
    if (_play.animate()) return true;
    if (_pause.animate()) return true;
    return refresh;
  }
  
  
  void pulse() {
    _play.pulse();
  }

  
  bool get isInProgram => true;

  
  /**
   * Draw the block
   */
  void draw(CanvasRenderingContext2D ctx) {
    super.draw(ctx);
    _play.x = x + 65;
    _play.y = y + height/2 - 15;
    _pause.x = x + 65;
    _pause.y = y + height/2 - 15;
    _play.visible = !workspace.running;
    _pause.visible = workspace.running;
    _play.draw(ctx);
    _pause.draw(ctx);
  }

  
  bool isOutOfBounds() {
    return (y < getStartY() - getProgramHeight() - 100.0 ||
            y + getProgramHeight() > workspace.height ||
            x < 0 || x + width > workspace.width);
  }
  
  
  bool touchDown(Contact c) {
    dragging = false;
    _target = null;
    if (_play.containsTouch(c)) {
      _target = _play;
      _play.touchDown(c);
    } else if (_pause.containsTouch(c)) {
      _target = _pause;
      _pause.touchDown(c);
    }
    _lastX = c.touchX;
    _lastY = c.touchY;
    workspace.draw();
    return true;
  }
  
  
  void touchDrag(Contact c) {
    if (_target == null) {
      moveChain(c.touchX - _lastX, c.touchY - _lastY);
    } else {
      _target.touchDrag(c);
    }
    _lastX = c.touchX;
    _lastY = c.touchY;
    workspace.draw();
  }
  
  
  void touchUp(Contact c) {
    dragging = false;
    if (_target != null) {
      _target.touchUp(c);
    }
    else if (isOutOfBounds()) {
      _targetX = getStartX();
      end._targetY = getStartY() + height;
    }
    _target = null;
    workspace.draw();
  }
}



/**
* Visual programming block
*/
class EndProgramBlock extends EndBlock {
    //color = '#a00';

  
  EndProgramBlock(CodeWorkspace workspace, StartBlock begin) : super(workspace, begin) {
    _width = (BLOCK_WIDTH + BLOCK_MARGIN).toDouble();
    wasInMenu = false;
  }
  
  
  bool touchDown(Contact c) {
    return false;
  }
}

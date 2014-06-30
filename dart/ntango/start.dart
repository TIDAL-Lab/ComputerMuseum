/*
 * Computer History Museum Frog Pond
 * Copyright (c) 2014 Michael S. Horn
 * 
 *           Michael S. Horn (michael-horn@northwestern.edu)
 *           Northwestern University
 *           2120 Campus Drive
 *           Evanston, IL 60613
 *           http://tidal.northwestern.edu
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation.
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
part of NetTango;


/**
 * Start block
 */
class StartBlock extends BeginBlock {
  
  StartBlock(CodeWorkspace workspace) : super(workspace, 'start') {
    x = getStartX();
    y = getStartY();
    color = 'green';
    end = new EndProgramBlock(workspace, this);
    end.y = y + height + BLOCK_MARGIN + 20;
    _addClause(end);
    workspace.addBlock(end);
    inserted = true;
    _width = (BLOCK_WIDTH + BLOCK_MARGIN).toDouble();
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
  
  
  bool get isInProgram => true;

  
  bool touchDown(Contact c) {
    dragging = false;
    _lastX = c.touchX;
    _lastY = c.touchY;
    workspace.draw();
    return true;
  }
  
  
  void touchDrag(Contact c) {
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
    _width = (BLOCK_WIDTH + BLOCK_MARGIN).toDouble();
    inserted = true;
  }

  
  Block step(Program program) {
    return AUTO_REPEAT ? begin : null;
  }  

  
  bool touchDown(Contact c) {
    return false;
  }
}

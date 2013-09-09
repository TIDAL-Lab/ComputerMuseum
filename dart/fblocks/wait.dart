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

  
class WaitBlock extends BeginBlock {

  TimeoutBlock timeout;
  
  WaitBlock(CodeWorkspace workspace) : super(workspace, 'wait\nfor') {
    param = new Parameter(this);
    param.values = [ 'fly', 'sound' ];
    timeout = new TimeoutBlock(workspace, this);
    _addClause(timeout);
    end = new EndBlock(workspace, this);
    _addClause(end);
    
  }

  
  Block clone() {
    WaitBlock block = new WaitBlock(workspace);
    copyTo(block);
    block.text = text;
    return block;
  }
  
  
  Block step(Program program) {
    var v = timeout.param.value;
    int t = (v is int) ? v * 20 : Turtle.rand.nextInt(6000);

    if (!program.hasVariable("timeout")) {
      program["timeout"] = t;
    }
    
    if (program.getSensorValue(param.value)) {
      program.removeVariable("timeout");
      return next;
    }
    
    else if (program["timeout"] <= 0) {
      program.removeVariable("timeout");
      program["do-timeout${timeout.id}"] = true;
      return timeout;
    }
    
    else {
      program["timeout"] --;
      return this;
    }
  }
}


class TimeoutBlock extends ControlBlock {
  
  TimeoutBlock(CodeWorkspace workspace, BeginBlock begin) : super(workspace, begin, 'timeout') {
    param = new Parameter(this);
    param.values = [ 10, 50, 100, 150, 200, 'random' ];
    param.centerX = width - 12;
    param.index = 5;
  }
  
  
  Block step(Program program) {
    String v = "do-timeout${id}";
    if (program.hasVariable(v)) {
      program.removeVariable(v);
      return next;
    } else {
      return begin.end;
    }
  }
}
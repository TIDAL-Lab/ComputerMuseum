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

  WaitBlock(CodeWorkspace workspace) : super(workspace, 'wait for fly') {
    //param = new Parameter(this);
    //param.centerX = width - 7;
    //param.values = [ 50, 100, 150, 200, 250, 300, 350, 400 ];
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
    //var v = param.value;
    //int t = (v is int) ? v * 20 : Turtle.rand.nextInt(6000);
    int t = 400;

    if (!program.hasVariable("timeout")) {
      program["timeout"] = t;
    }
    
    if (program.getSensorValue("fly")) {
      program.removeVariable("timeout");
      return next;
    }
    else if (program["timeout"] <= 0) {
      program.removeVariable("timeout");
      return end;
    }
    else {
      program["timeout"] --;
      return this;
    }
  }
}

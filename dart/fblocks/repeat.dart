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
    param = new Parameter(this);
    param.centerX = width - 7;
    param.values = [ 'forever', 2, 3, 4, 5, 'near-water?' ];
    end = new EndBlock(workspace, this);
    _addClause(end);
  }
  
  
  Block clone() {
    RepeatBlock block = new RepeatBlock(workspace);
    copyTo(block);
    return block;
  }
  
  
  Block _endStep(Program program) {
    return this;
  }
  
  
  void parameterChanged(Parameter param) {
    if (param.value == "near-water?") {
      text = "repeat\nuntil";
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
    
    // counting loop
    if (param.value is int) {
      int p = param.value as int; 
      String v = "repeat-counter-${id}";
      
      if (!program.hasVariable(v) || param.changed) {
        program[v] = p;
        param.changed = false;
      } else {
        p = program[v] as int;
      }
    
      if (p <= 0) {
        program.removeVariable(v);
        return end.next;
      } else {
        program[v] = p - 1;
        return next;
      }
    }
    
    // infinite loop
    else if (param.value == "forever") {
      return next;
    }
    
    // conditional loops
    else if (param.value == "near-water?") {
      return program.getSensorValue(param.value) ? end.next : next;
    }
    
    else {
      return next;
    }
  }
}



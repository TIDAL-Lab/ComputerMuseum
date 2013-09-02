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
    param.values = [ 2, 3, 4, 5, 'forever', 'near-water?', 'see-gem?' ];
  }
  
  
  Block clone() {
    RepeatBlock block = new RepeatBlock(workspace);
    copyTo(block);
    return block;
  }
  
  
  void parameterChanged(Parameter param) {
    if (param.value == "near-water?" || param.value == "see-gem?") {
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
    String v = "repeat-counter-${id}";
    if (!program.hasVariable(v) || param.changed) {
      program[v] = param.value;
      param.changed = false;
    }
    
    var p = program[v];
    
    // counting loop
    if (p is int) {
      if (p <= 0) {
        program.removeVariable(v);
        return end.next;
      } else {
        program[v] = p - 1;
        return next;
      }
    }
    
    // infinite loop
    else if (p == "forever") {
      return next;
    }
    
    // conditional loops
    // TODO!!
    /*
    else if (param.value == "near-water?") {
      return frog.nearWater() ? end.next : next;
    }
    
    else if (param.value == "see-gem?") {
      return frog.seeGem() ? end.next : next;
    }
    */
    else {
      return next;
    }
  }

  
  void touchUp(Contact c) {
    super.touchUp(c);
    if (end == null && isInProgram) {
      end = new EndRepeat(workspace, this);
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

  EndRepeat(CodeWorkspace workspace, BeginBlock begin) : super(workspace, begin);  

  
  Block step(Program program) {
    return begin;
  }
}

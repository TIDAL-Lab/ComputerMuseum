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


class IfBlock extends BeginBlock {
  
  IfBlock(CodeWorkspace workspace) : super(workspace, 'if') {
    end = new EndBlock(workspace, this);
    _addClause(end);
  }
  
  
  Block clone() {
    IfBlock block = new IfBlock(workspace);
    copyTo(block);
    return block;
  }

  
  String compile(int indent) {
    String tab = "";
    for (int i=0; i<indent; i++) tab += "  ";
    return "${tab}if (${param.value}) {\n";
  }
  
  
  Block step(Program program) {
    if (program.getSensorValue(param.value)) {
      return next;
    } else {
      return end.next;
    }
  }
}



class IfElseBlock extends BeginBlock {
  
  ElseBlock el;

  IfElseBlock(CodeWorkspace workspace) : super(workspace, 'if-else') {
    el = new ElseBlock(workspace, this);
    _addClause(el);
    
    end = new EndBlock(workspace, this);
    _addClause(end);
  }
  
  
  Block clone() {
    IfElseBlock block = new IfElseBlock(workspace);
    copyTo(block);
    return block;
  }
  
  
  String compile(int indent) {
    String tab = "";
    for (int i=0; i<indent; i++) tab += "  ";
    return "${tab}if (${param.value}) {\n";
  }
  
  
  Block step(Program program) {
    if (program.getSensorValue(param.value)) {
      program["if${id}"] = "if-branch";
      return next;
    } else {
      program["if${id}"] = "else-branch";
      return el;
    }
  }
}


class ElseBlock extends ControlBlock {
  
  ElseBlock(CodeWorkspace workspace, BeginBlock begin) : super(workspace, begin, 'else');
  
  Block step(Program program) {
    if (program["if${begin.id}"] == "else-branch") {
      return next;
    } else {
      return begin.end.next;
    }
  }
  
  String compile(int indent) {
    String tab = "";
    for (int i=0; i<indent-1; i++) tab += "  ";
    return "${tab}else {\n";
  }  
}

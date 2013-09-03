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

  
class IfBlock extends BeginBlock {

  IfBlock(CodeWorkspace workspace) : super(workspace, 'if') {
    param = new Parameter(this);
    param.centerX = width - 35;
    param.values = [ 'see-gem?', 'near-water?', 'not see-gem?', 'not near-water?', 'random?' ];
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
    return program.getSensorValue(param.value) ? next : end.next;
  }
}


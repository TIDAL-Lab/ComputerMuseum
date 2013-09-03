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
    color = '#c92';
    param = new Parameter(this);
    param.values = [ 'see-fly?', 'near-water?', 'random?' ];
  }
  
  
  Block clone() {
    IfBlock block = new IfBlock(workspace);
    block.x = x;
    block.y = y;
    return block;
  }
  
  

  void touchUp(Contact c) {
    super.touchUp(c);
    if (end == null && isInProgram) {
      end = new EndIf(workspace, this);
      end.begin = this;
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



class EndIf extends EndBlock {
  
  
  EndIf(CodeWorkspace workspace, BeginBlock begin) : super(workspace, begin) {
    color = '#c92';
    this.x = x;
    this.y = y;
  }

  
  Block clone() {
    return new EndIf(workspace, begin);
  }
  
  
  void touchUp(Contact c) {
    super.touchUp(c);
    if (!isInProgram) {
      begin.next.prev = begin.prev;
      begin.prev.next = begin.next;
      begin.prev = null;
      begin.next = null;
      workspace.removeBlock(begin);
      begin = null;
    }
  }
}

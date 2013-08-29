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

  
class BeginBlock extends Block {
  
  EndBlock end = null;

  
  BeginBlock(CodeWorkspace workspace, String text) : super(workspace, text);
  
  
/**
 * Make sure blocks are properly nested
 */
  bool checkSyntax(Block before) {

    int nest = 0;
    if (end == null) return true;
    Block after = before.next;
    
    while (after != null) {
      if (after == end) {
        return (nest == 0);
      } else if (after is EndBlock) {
        nest--;
      } else if (after is BeginBlock) {
        nest++;
      }
      after = after.next;
    }
    return false;
  }
}


class EndBlock extends Block {
  
  BeginBlock begin = null;
  
  
  EndBlock(CodeWorkspace workspace, String text) : super(workspace, text);
  
  
  double getBottomLine() {
    int nest = 1;
    Block b = prev;
    while (b != begin && b != null) {
      if (b is EndBlock) nest++;
      b = b.prev;
    }
    return y + height + BLOCK_MARGIN * nest;
  }
  
  
  bool checkSyntax(Block before) {
    if (before is EndProgramBlock) return false;
    int nest = 0;
    while (before != null) {
      if (before == begin) {
        return (nest == 0);
      } else if (before is EndBlock) {
        nest++;
      } else if (before is BeginBlock) {
        nest--;
      }
      before = before.prev;
    }
    return false;
  }  
  
}

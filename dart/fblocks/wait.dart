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

  
class WaitBlock extends Block {

  
  WaitBlock(CodeWorkspace workspace) : super(workspace, 'wait for') {
    color = '#c92';
    param = new Parameter(this);
    param.values = [ 'fly', 'sound', 1, 2, 3, 'random' ];
  }

  
  Block clone() {
    WaitBlock block = new WaitBlock(workspace);
    block.x = x;
    block.y = y;
    block.text = text;
    block.param.values = param.values;
    return block;
  }
  
  
  void eval(Frog frog, [bool preview = false]) {
    if (param.value == 1) {
      frog.doWait("wait for 1 second", param);
    } else if (param.value is num || param.value == "random") {
      frog.doWait("wait for ${param.value} seconds", param);
    } else {
      frog.doWait("wait for ${param.value}", param);
    }
  }
  
  
  Block step(Frog frog) {
    if (param.value == "fly") {
      return (frog.nearFly()) ? next : this;
    } else if (param.value == "sound") {
      return (frog.hearSound()) ? next : this;
    } else {
      return next;
    }
  }
}
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


class Program {
  
  /* Owner of this program */
  Frog frog;

  /* Start block for the program */
  StartBlock start;
  
  /* Currently executing statement in the program */
  Block curr;
  
  /* Is the program running? */
  bool running = false;
  
  
  Program(this.frog, this.start);
  
  
  Program.copy(Frog frog, Program other) {
    this.frog = frog;
    start = other.start;
    curr = other.curr;
    running = other.running;
  }
  
  
  void restart() {
    curr = start;
    frog.clearVariables();
    running = false;
  }
  
  
  void play() {
    running = true;
    curr = start;
  }
  
  
  void pause() {
    running = false;
  }
  
  
  bool get isRunning {
    return (running && curr != null);
  }
  
  
  void skip() {
    if (isRunning) {
      curr = curr.step(frog);
    }
  }

  
  void step() {
    if (isRunning) {
      curr.eval(frog);
      curr = curr.step(frog);
    }
  }
}  

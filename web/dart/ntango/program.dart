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


abstract class Program {
  
  /* Start block for the program */
  StartBlock start;
  
  /* Currently executing statement in the program */
  Block curr = null;
  
  /* Is the program running? */
  bool running = false;
  
  /* variable storage */
  Map<String, dynamic> variables = new Map<String, dynamic>();
  
  
  Program(CodeWorkspace workspace) {
    start = workspace.start;
  }
  
  
  void synchronize(Program other) {
    curr = other.curr;
  }
  
  
  bool getSensorValue(String sensor);

  
  void doCommand(String cmd, var param);
  
  
  dynamic operator[] (String key) {
    return variables[key];
  }
  
  
  void operator[]=(String key, var value) {
    variables[key] = value;
  }
  
  
  bool hasVariable(String name) {
    return variables.containsKey(name);
  }
  
  
  void removeVariable(String name) {
    variables.remove(name);
  }
  
  
  void clearVariables() {
    variables.clear();
  }
  
  
  void step() {
    if (isRunning) {
      curr = curr.step(this);
      if (curr != null) curr.eval(this);
    }
  }

  
  void restart() {
    curr = start;
    running = false;
  }
  
  
  void play() {
    if (isFinished) restart();
    running = true;
  }
  
  
  void pause() {
    running = false;
  }
  
  
  bool get isRunning {
    return (running && curr != null);
  }
  
  
  bool get isPaused {
    return (!running && curr != null);
  }
  
  
  bool get isFinished {
    return (curr == null);
  }
  
  
  String compile() {
    String s = "void main() {\n";
    Block b = start.next;
    int indent = 1;
    while (b != null && !(b is EndProgramBlock)) {
      s += b.compile(indent);
      if (b is BeginBlock) {
        indent++;
      } else if (b is EndBlock) {
        indent--;
      }
      b = b.next;
    }
    return s + "}\n";
  }
  
}  

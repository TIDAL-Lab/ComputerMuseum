/*
 * Computer History Museum Frog Pond
 * Copyright (c) 2014 Michael S. Horn
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


class AgentSet {
  
  List<Turtle> agents = new List<Turtle>();
  
  TouchLayer tlayer;
  
  
  AgentSet(this.tlayer) { }
  
  
  int get length => agents.length;
  
  
  void add(Turtle agent) {
    agents.add(agent);
    if (tlayer != null) tlayer.addTouchable(agent as Touchable);
  }
  
  
  void erase(CanvasRenderingContext2D ctx) {
    agents.forEach((t) => t.erase(ctx));
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    agents.forEach((t) => t.draw(ctx));
  }
  
  
  bool animate() {
    bool refresh = false;
    // use a backwards for loop to prevent concurrent modification errors (when new turtles get added)
    for (int i = agents.length; i > 0; i--) {
      if (agents[i-1].animate()) refresh = true;
    }
    return refresh;
  }
  
  
  void remove(Turtle agent) {
    agents.remove(agent);
    if (tlayer != null) tlayer.removeTouchable(agent as Touchable);
  }
  
  
  bool removeDead() {
    int count = 0;
    for (int i=agents.length - 1; i >= 0; i--) {
      if (agents[i].dead) {
        remove(agents[i]);
        count++;
      }
    }
    return count > 0;
  }
  
  
  Set<Turtle> getTurtlesHere(Turtle target) {
    Set<Turtle> aset = new HashSet<Turtle>();
    for (Turtle t in agents) {
      if (t != target && t.overlapsTurtle(target)) {
        aset.add(t);
      }
    }
    return aset;
  }
  
  
  Turtle getTurtleHere(Turtle target) {
    Set<Turtle> aset = getTurtlesHere(target);
    return aset.isEmpty ? null : aset.first;
  }
  
  
  Turtle getTurtleAtPoint(num px, num py) {
    for (Turtle t in agents) {
      if (t.overlapsPoint(px, py)) {
        return t;
      }
    }
    return null;
  }
  
  
  Set<Turtle> getTurtlesWith(Function criterion) {
    Set<Turtle> aset = new HashSet<Turtle>();
    for (Turtle t in agents) {
      if (criterion(t)) aset.add(t);
    }
    return aset;
  }
  
  
  Turtle getTurtleWith(Function criterion) {
    Set<Turtle> aset = getTurtlesWith(criterion);
    return aset.isEmpty ? null : aset.first;
  }
  
  
  int getCountWith(Function criterion) {
    return getTurtlesWith(criterion).length;
  }
}

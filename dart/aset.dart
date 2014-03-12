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


class AgentSet<T> {
  
  List<T> agents = new List<T>();
  
  TouchLayer tlayer = null;
  
  
  AgentSet() { }
  
  
  int get length => agents.length;
  
  T get first => (agents.isEmpty ? null : agents.last);
  
  
  void add(T agent) {
    if (agent is Turtle) {
      agents.add(agent);
      if (tlayer != null) tlayer.addTouchable(agent as Touchable);
    } else {
      throw "Invalid agent type. Must be subclass of type Turtle";
    }
  }
  
  
  void remove(T agent) {
    agents.remove(agent);
    if (tlayer != null) tlayer.removeTouchable(agent as Touchable);
  }
  
  
  void moveToTop(T agent) {
    remove(agent);
    add(agent);
  }
  
  
  void erase(CanvasRenderingContext2D ctx) {
    agents.forEach((t) => (t as Turtle).erase(ctx));
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    agents.forEach((t) => (t as Turtle).draw(ctx));
  }
  
  
  bool animate() {
    bool refresh = false;
    // use a backwards for loop to prevent concurrent modification errors (when new turtles get added)
    for (int i = agents.length; i > 0; i--) {
      if ((agents[i-1] as Turtle).animate()) refresh = true;
    }
    return refresh;
  }
  
  
  bool removeDead() {
    int count = 0;
    for (int i=agents.length - 1; i >= 0; i--) {
      if ((agents[i] as Turtle).dead) {
        remove(agents[i]);
        count++;
      }
    }
    return count > 0;
  }
  
  
  Set<T> getTurtlesHere(Turtle target) {
    Set<T> aset = new HashSet<T>();
    for (T t in agents) {
      if (t != target && (t as Turtle).overlapsTurtle(target)) {
        aset.add(t);
      }
    }
    return aset;
  }
  
  
  T getTurtleHere(Turtle target) {
    Set<T> aset = getTurtlesHere(target);
    return aset.isEmpty ? null : aset.first;
  }
  
  
  T getTurtleAtPoint(num px, num py) {
    for (T t in agents) {
      if ((t as Turtle).overlapsPoint(px, py)) {
        return t;
      }
    }
    return null;
  }
  
  
  Set<T> getTurtlesWith(Function criterion) {
    Set<T> aset = new HashSet<T>();
    for (T t in agents) {
      if (criterion(t)) aset.add(t);
    }
    return aset;
  }
  
  
  T getTurtleWith(Function criterion) {
    Set<T> aset = getTurtlesWith(criterion);
    return aset.isEmpty ? null : aset.first;
  }
  
  
  int getCountWith(Function criterion) {
    return getTurtlesWith(criterion).length;
  }
}

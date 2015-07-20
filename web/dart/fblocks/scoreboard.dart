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

  
/**
 * Scoreboard for number of bugs caught
 */
class Scoreboard {

  /* Dimensions of the scoreboard */
  num x, y, w, h;
  
  /* Beetle scoreboard */
  Map<String, Beetle> beetles = new Map<String, Beetle>();
  
  /* Tallies */
  Map<String, int> scores = new Map<String, int>();
  
  
  Scoreboard(FrogWorkspace workspace, this.x, this.y, this.w, this.h) {
    // scoreboard
    num bx = x + w - 30;
    for (String color in Beetle.colors) {
      Beetle b = new Beetle(workspace.pond, color);
      beetles[color] = b;
      scores[color] = 0;
      b.x = bx.toDouble();
      b.y = y + h/2;
      b.heading = 0.0;
      b.perched = true;
      b.locked = true;
      b.shadowed = true;
      bx -= 40;
    }
  }
  
  
  void reset() {
    for (String color in beetles.keys) {
      beetles[color].shadowed = true;
      scores[color] = 0;
    }
  }

  
  void captureBug(Beetle bug) {
    beetles[bug.color].shadowed = false;
    beetles[bug.color].pulse();
    if (scores[bug.color] < 9) {
      scores[bug.color]++;
    }
  }
  
  
  bool animate() {
    for (Beetle beetle in beetles.values) {
      if (beetle.animate()) return true;
    }
    return false;
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save();
    for (String color in beetles.keys) {
      Beetle b = beetles[color];
      b.draw(ctx);
      if (scores[color] > 0) {
        ctx.fillStyle = 'rgba(255, 100, 0, 0.8)';
        ctx.strokeStyle = 'white';
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.arc(b.x - 15, b.y - 30, 11, 0, PI * 2, true);
        ctx.fill();
        ctx.stroke();
        ctx.textBaseline = 'middle';
        ctx.textAlign = 'center';
        ctx.fillStyle = 'white';
        ctx.font = '400 12px sans-serif';
        ctx.fillText(scores[color].toString(), b.x - 15, b.y - 30);
      }
    }
    ctx.restore();
  }
} 

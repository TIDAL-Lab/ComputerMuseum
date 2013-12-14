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

const MARGIN = 20.5;
const GAP = 6;


class Histogram {
  
  int width = 300;
  int height = 300;
  
  FrogPond pond;
  
  int bins = 5;
  
  CanvasRenderingContext2D ctx;
  
  ImageElement frog = new ImageElement();
  
  List<double> values = new List<double>();
  
  
  Histogram(String name, this.pond) {
    CanvasElement canvas = querySelector("#$name");
    ctx = canvas.getContext('2d');
    width = canvas.width;
    height = canvas.height;
    values = new List<double>(bins);
    frog.src = "images/whitefrog.png";
  }
  
  
  void recalculate() {
    double bottom = 0.1;
    double range = (3.0 - bottom);
    double bin = range / bins;
    List<int> counts = new List<int>(bins);
    for (int i=0; i<bins; i++) {
      counts[i] = 0;
    }
    
    for (Frog frog in pond.frogs) {
      if (frog.size >= 1.6) {
        counts[4]++;
      } else if (frog.size >= 0.8) {
        counts[3]++;
      } else if (frog.size >= 0.4) {
        counts[2]++;
      } else if (frog.size >= 0.2) {
        counts[1]++;
      } else {
        counts[0]++;
      }
    }
    
    if (pond.frogs.length > 0) {
      for (int i=0; i<bins; i++) {
        values[i] = counts[i] / pond.frogs.length;
      }
    }
  }
  
  
  void draw() {
    recalculate();
    
    ctx.clearRect(0, 0, width, height);
    
    double gx = MARGIN;
    double gy = MARGIN;
    double gw = width - MARGIN * 2 + 0.5;
    double gh = height - MARGIN * 6 + 0.5;
    
    ctx.strokeStyle = "white";
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(gx, gy + gh);
    ctx.lineTo(gx + gw, gy + gh);
    ctx.stroke();
    
    num iw = frog.width * 0.3;
    num ih = frog.height * 0.3;
    
    gx += MARGIN;
    gw -= MARGIN * 2;
    double bw = gw / bins;
    double bx = gx;
    double bh = 130.0;
    double by = gy + gh - bh;
    double id = 0.2;
    
    ctx.fillStyle = "white";
    for (int i=0; i<bins; i++) {
      
      bh = gh * values[i];
      by = gy + gh - bh;
      
      iw = frog.width * id;
      ih = frog.height * id;
      id += 0.1;
      
      ctx.fillRect(bx + GAP, by, bw - GAP * 2, bh);
      ctx.drawImageScaled(frog, bx + bw/2 - iw/2, gy + gh + 8, iw, ih);
      bx += bw;
    }
  }
}


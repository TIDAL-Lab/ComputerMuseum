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
library Plotting;

import 'dart:html';
import 'dart:math';

const MARGIN = 20.5;


void main() {
  new Histogram("plot");
}


int getIntParameter(String name, [ defaultValue = 0 ]) {
  String q = window.location.search;
  if (q.startsWith('?')) q = q.substring(1);
  var params = q.split('&');
  for (var param in params) {
    if (param.startsWith('$name=')) {
      var tuple = param.split('=');
      if (tuple.length == 2) {
        return int.parse(tuple[1]);
      } else {
        return defaultValue;
      }
    }
  }
  return defaultValue;
}


class Histogram {
  
  
  List<double> values = new List<double>();
  List<String> labels = new List<String>();
  int width = 300;
  int height = 300;
  
  CanvasRenderingContext2D ctx;
  
  Histogram(String name) {
    
    window.onMessage.listen((e) => print("message"));
    CanvasElement canvas = document.query("#$name");
    ctx = canvas.getContext('2d');
    canvas.width = getIntParameter("width", canvas.width);
    canvas.height = getIntParameter("height", canvas.height);
    width = canvas.width;
    height = canvas.height;
    values.add(0.1);
    values.add(0.5);
    values.add(0.2);
    values.add(0.15);
    values.add(0.05);
    labels.add('small');
    labels.add('medium');
    labels.add('large');
    labels.add('huge');
    labels.add('gargantuan');
    draw(ctx);
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.clearRect(0, 0, width, height);
    ctx.fillStyle = 'white';
    //ctx.fillRect(0, 0, width, height);
    double gx = MARGIN * 2 + 0.5;
    double gy = MARGIN;
    double gw = width - MARGIN * 3 + 0.5;
    double gh = height - MARGIN * 3 + 0.5;
    //ctx.fillRect(gx, gy, gw, gh);
    ctx.strokeStyle = '#444';
    ctx.strokeRect(gx, gy, gw, gh);
    
    ctx.font = "200 12px sans-serif";
    ctx.fillStyle = "black";
    ctx.textAlign = "right";
    ctx.textBaseline = "middle";
    double tx = gx - 8;
    double ty = gy + gh;
    for (int i=0; i<=4; i+=2) {
      ty = gy + gh - i * gh / 4;
      ctx.fillText("${i * 25}%", tx, gy + gh - i * gh / 4);
      ctx.beginPath();
      ctx.moveTo(tx + 4, ty);
      ctx.lineTo(tx + 12, ty);
      ctx.stroke();
    }
    
    int bins = values.length;
    double th, tw;
    ctx.textAlign = "center";
    ctx.textBaseline = "top";
    for (int i=0; i<bins; i++) {
      tw = gw / bins;
      th = gh * values[i];
      tx = gx + i * tw;
      ty = gy + gh - th;
      ctx.fillStyle = 'rgba(0, 50, 200, 0.4)';
      ctx.fillRect(tx + 1, ty, tw - 1, th - 1);
      ctx.fillStyle = 'black';
      ctx.fillText(labels[i], tx + tw/2, gy + gh + 4);
    }
  }
}


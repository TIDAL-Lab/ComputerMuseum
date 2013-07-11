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


class FrogPond {
  
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  
  CodeWorkspace workspace;  
  
  int width, height;
  
  ImageElement lilypad = new ImageElement();
  
  
  FrogPond(String id) {
    canvas = document.query("#${id}");
    ctx = canvas.getContext('2d');
    width = canvas.width;
    height = canvas.height;
    lilypad.src = "images/lilypad.png";
    //registerEvents(canvas);
    
    workspace = new CodeWorkspace(canvas, this);
    new Timer.periodic(const Duration(milliseconds : 40), animate);
    draw();
  }
  
  
  
  void animate(Timer timer) {
    if (workspace.animate()) draw();
  }
  
  
  void draw() {
    ctx.clearRect(0, 0, width, height);
    ctx.drawImage(lilypad, 200, 20);
    workspace.draw(ctx);
  }
  
}

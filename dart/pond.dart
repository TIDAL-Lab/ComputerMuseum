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
  CanvasRenderingContext2D background;
  CanvasRenderingContext2D foreground;
  
  CodeWorkspace workspace;  
  
  int width, height;
  
  ImageElement lilypad = new ImageElement();
  
  
  FrogPond() {
    canvas = document.query("#background");
    background = canvas.getContext('2d');
    width = canvas.width;
    height = canvas.height;
    
    canvas = document.query("#foreground");
    foreground = canvas.getContext('2d');
    
    lilypad.src = "images/lilypad.png";
    lilypad.onLoad.listen((event) => drawBackground());
    
    workspace = new CodeWorkspace(this, width, height);
    new Timer.periodic(const Duration(milliseconds : 40), animate);
  }
  
  
  
  void animate(Timer timer) {
    if (workspace.animate()) drawForeground();
  }
  
  
  bool inWater(num x, num y) {
    ImageData imd = background.getImageData(x.toInt(), y.toInt(), 1, 1);
    int r = imd.data[0];
    int g = imd.data[1];
    int b = imd.data[2];
    // value of background water texture is all zero since it's from CSS
    return (g == 0);
  }

  
  void drawBackground() {
    CanvasRenderingContext2D ctx = background;
    ctx.clearRect(0, 0, width, height);
    ctx.drawImage(lilypad, 200, 20);
  }
  
  
  void drawForeground() {
    CanvasRenderingContext2D ctx = foreground;
    ctx.clearRect(0, 0, width, height);
    workspace.draw(ctx);
  }
}

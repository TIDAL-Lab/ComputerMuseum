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
  
  List<CodeWorkspace> workspaces = new List<CodeWorkspace>();
  
  int width, height;
  
  List<Gem> gems = new List<Gem>();
  
  List<Fly> flies = new List<Fly>();
  
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

    addRandomGem();
    
    for (int i=0; i<5; i++) {
      addRandomFly();
    }
    
    workspaces.add(new CodeWorkspace(this, width, height));
    new Timer.periodic(const Duration(milliseconds : 40), animate);
    new Timer.periodic(const Duration(milliseconds : 800), (timer) => drawBackground());
  }
  
  
  void animate(Timer timer) {
    bool repaint = false;
    
    // remove dead gems
    for (int i=gems.length-1; i >= 0; i--) {
      if (gems[i].dead) {
        gems.remove(gems[i]);
        repaint = true;
      }
    }    

    // animate gems
    for (Gem gem in gems) {
      if (gem.animate()) repaint = true;
    }
    
    // animate flies
    for (Fly fly in flies) {
      fly.animate();
      repaint = true;
    }
    
    for (CodeWorkspace workspace in workspaces) {
      if (workspace.animate()) repaint = true;
    }
    if (repaint) drawForeground();
  }
  
  
  bool inWater(num x, num y) {
    ImageData imd = background.getImageData(x.toInt(), y.toInt(), 1, 1);
    int r = imd.data[0];
    int g = imd.data[1];
    int b = imd.data[2];
    // value of background water texture is all zero since it's from CSS
    return (g == 0);
  }
  
  
  double _angleBetween(Turtle a, Turtle b) {
    double theta = -atan2(a.x - b.x, a.y - b.y) / PI * 180.0;
    if (theta < 0) theta += 360.0;
    double alpha = (a.heading / PI * 180.0) % 360;
    return alpha - theta;
  }
  
  
  bool seeGem(Frog frog) {
    for (Gem gem in gems) {
      if (_angleBetween(frog, gem).abs() < 20.0) return true;
    }
    return false;
  }
  
  
  bool nearFly(Frog frog) {
    for (Fly fly in flies) {
      if (_angleBetween(frog, fly).abs() < 10.0) {
        num d = distance(fly.x, fly.y, frog.x, frog.y);
        if (d > frog.height / 4 && d < frog.height * 1.5) {
          return true;
        }
      }
    }
    return false;
  }
  
  
  Gem getGemHere(Frog frog) {
    for (Gem gem in gems) {
      if (gem.overlaps(frog.x, frog.y, frog.width)) return gem;
    }
    return null;
  }
  
  
  Frog getFrogHere(num x, num y) {
    for (CodeWorkspace workspace in workspaces) {
      Frog frog = workspace.getFrogHere(x, y);
      if (frog != null) return frog;
    }
    return null;
  }
  
  
/**
 * Adds a new random fly to the pond
 */
  void addRandomFly() {
    flies.add(new Fly(this,
                      Turtle.rand.nextInt(width).toDouble(),
                      Turtle.rand.nextInt(height).toDouble()));
  }
  
  
  void removeFly(Fly fly) {
    flies.remove(fly);
  }
  
  
/**
 * Adds a random gem to the pond in a place where there are no frogs... give up
 * after a few tries and try again later.
 */
  void addRandomGem()  {
    for (int i=0; i<25; i++) {
      int x = Turtle.rand.nextInt(width - 100) + 50;
      int y = Turtle.rand.nextInt(height - 200) + 100;
      if (!inWater(x, y) && getFrogHere(x, y) == null) {
        Gem gem = new Gem();
        gem.x = x.toDouble();
        gem.y = y.toDouble();
        gem.size = 0.75;
        gems.add(gem);
        return;
      }
    }
    // try again in 4 seconds
    new Timer(const Duration(milliseconds : 4000), addRandomGem);
  }

  
  void drawBackground() {
    CanvasRenderingContext2D ctx = background;
    ctx.clearRect(0, 0, width, height);
    ctx.drawImage(lilypad, 200, 20);
    for (CodeWorkspace workspace in workspaces) {
      workspace.drawBackground(ctx);
    }
  }
  
  
  void drawForeground() {
    CanvasRenderingContext2D ctx = foreground;
    ctx.clearRect(0, 0, width, height);
    for (Gem gem in gems) {
      gem.draw(ctx);
    }
    
    for (CodeWorkspace workspace in workspaces) {
      workspace.draw(ctx);
    }
    
    for (Fly fly in flies) {
      fly.draw(ctx);
    }
  }
}

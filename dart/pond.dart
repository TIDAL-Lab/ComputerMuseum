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


class FrogPond extends TouchManager {
  
  CanvasElement canvas;
  CanvasRenderingContext2D layer0;  // lily pads
  CanvasRenderingContext2D layer1;  // status bar / menu
  CanvasRenderingContext2D layer2;  // foreground frogs / blocks
  
  List<CodeWorkspace> workspaces = new List<CodeWorkspace>();
  
  int width, height;
  
  /* List of gems on the screen */
  List<Gem> gems = new List<Gem>();

  /* List of flies */  
  List<Fly> flies = new List<Fly>();
  
  /* List of frogs */  
  List<Turtle> frogs = new List<Frog>();
  
  
  ImageElement lilypad = new ImageElement();
  
  
  FrogPond() {
    canvas = document.query("#pond");
    layer0 = canvas.getContext('2d');
    
    canvas = document.query("#background");
    layer1 = canvas.getContext('2d');
    
    canvas = document.query("#foreground");
    layer2 = canvas.getContext('2d');
    
    width = canvas.width;
    height = canvas.height;
    
    lilypad.src = "images/lilypad.png";
    lilypad.onLoad.listen((event) {
      layer0.clearRect(0, 0, width, height);
      layer0.drawImage(lilypad, 200, 20);
    });

    addGem();
    
    for (int i=0; i<10; i++) {
      addFly();
    }
    
    workspaces.add(new CodeWorkspace(this, width, height));
    new Timer.periodic(const Duration(milliseconds : 40), animate);
    new Timer.periodic(const Duration(milliseconds : 800), (timer) => drawBackground());
  }


  
/**
 * Add a frog to the pond
 */
  void addFrog(Frog frog) {
    frogs.add(frog);
    addTouchable(frog);
  }
  

/**
 * Remove a frog from the pond
 */
  void removeFrog(Frog frog) {
    frogs.remove(frog);
    removeTouchable(frog);
  }
  

/**
 * Remove dead frogs
 */
  void removeDeadFrogs() {
    for (int i=frogs.length-1; i >= 0; i--) {
      if (frogs[i].dead) removeFrog(frogs[i]);
    }
  }


/**
 * Returns any frog at the given location
 */
  Frog getFrogHere(num x, num y) {
    for (Frog frog in frogs) {
      if (frog.overlaps(x, y)) return frog;
    }
    return null;
  }
  
  
/**
 * Adds a new random fly to the pond
 */
  void addFly() {
    flies.add(new Fly(this,
                      Turtle.rand.nextInt(width).toDouble(),
                      Turtle.rand.nextInt(height).toDouble()));
  }
  
  
/**
 * Remove dead flies
 */
  void removeDeadFlies() {
    for (int i=flies.length-1; i >= 0; i--) {
      if (flies[i].dead) flies.removeAt(i);
    }
  }


/**
 * Returns the fly at the given location
 */
  Fly getFlyHere(num x, num y) {
    for (Fly fly in flies) {
      if (fly.overlaps(x, y, 20)) return fly;
    }
    return null;
  }
  
  
/**
 * Adds a random gem to the pond in a place where there are no frogs... give up
 * after a few tries and try again later.
 */
  void addGem()  {
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
    new Timer(const Duration(milliseconds : 4000), addGem);
  }

  
/**
 * Remove dead gems
 */
  void removeDeadGems() {
    for (int i=gems.length-1; i >= 0; i--) {
      if (gems[i].dead) gems.removeAt(i);
    }
  }
  
  
/**
 * Get any gem at this location 
 */
  Gem getGemHere(num x, num y) {
    for (Gem gem in gems) {
      if (gem.overlaps(x, y, 65.0)) {
        return gem;
      }
    }
  }
  
  
/**
 * Animate all of the agents and the workspaces
 */
  void animate(Timer timer) {

    // remove dead frogs, flies, and gems
    removeDeadGems();
    removeDeadFlies();
    removeDeadFrogs();
    
    // animate agents and workspaces
    gems.forEach((gem) => gem.animate());
    flies.forEach((fly) => fly.animate());
    frogs.forEach((frog) => frog.animate());
    workspaces.forEach((workspace) => workspace.animate());
    
    // redraw
    drawForeground();
  }
  

/**
 * Returns true if the given point is in the water
 */
  bool inWater(num x, num y) {
    ImageData imd = layer0.getImageData(x.toInt(), y.toInt(), 1, 1);
    int r = imd.data[0];
    int g = imd.data[1];
    int b = imd.data[2];
    return (g == 0); // value of background water texture is all zero since it's from CSS
  }
  
  
/**
 * Draw the menu and status areas
 */
  void drawBackground() {
    CanvasRenderingContext2D ctx = layer1;
    ctx.clearRect(0, 0, width, height);
    for (CodeWorkspace workspace in workspaces) {
      workspace.drawBackground(ctx);
    }
  }
  
  
/**
 * Draws the flies, frogs, gems, and programming blocks
 */
  void drawForeground() {
    CanvasRenderingContext2D ctx = layer2;
    ctx.clearRect(0, 0, width, height);
    
    workspaces.forEach((workspace) => workspace.draw(ctx));    

    gems.forEach((gem) => gem.draw(ctx));

    frogs.forEach((frog) => frog.draw(ctx));
    
    flies.forEach((fly) => fly.draw(ctx));

    frogs.forEach((frog) => frog.drawProgram(ctx));
  }
}

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


class FrogWorkspace extends CodeWorkspace {
  
  /* reference to the frog pond */
  FrogPond pond;
  
  /* list of frogs controlled by this workspace */
  AgentSet<Frog> frogs = new AgentSet<Frog>();

  /* bug scoreboard */
  Scoreboard scoreboard;
  
  /* is the program currently running? */
  bool running = false;
  
  
  FrogWorkspace(this.pond, int width, int height, String name) : super(width, height, name) {
    
    frogs.tlayer = pond;
    
    // bug scoreboard
    scoreboard = new Scoreboard(this, width - 150, height - BLOCK_HEIGHT * 1.85, 150, BLOCK_HEIGHT * 1.85);
    
    help.show();
  }
  
  
/**
 * Adds a new frog for the given workspace
 */
  Frog addHomeFrog() {
    Frog frog = new Frog(pond, this);
    frog["workspace"] = name;
    double fx = width / 2;
    double fy = height - 290.0;
    frog.x = objectToWorldX(fx, fy);
    frog.y = objectToWorldY(fx, fy);
    frog.heading = objectToWorldTheta(0);
    frog.img.src = "images/${name}frog.png";
    frogs.add(frog);
    return frog;
  }
  
  
/**
 * Frog to trace program execution
 */
  Frog getFocalFrog() {
    return frogs.first;
  }
  
  
/**
 * Called when user moves a block on the screen
 */
  void programChanging() {
    stopProgram();
  }
  
  
/**
 * Called when the program structure changes
 */
  void programChanged() {
    Logging.logEvent("${name}-program-changed", toString());
    stopProgram();
  }
  
  
/**
 * Resume the program for all frogs
 */
  void playProgram() {
    Logging.logEvent("play-${name}-program");
    if (frogs.length == 0) addHomeFrog();
    for (Frog frog in frogs.agents) {
      frog.program.play();
    }
  }

  
/**
 * Pause a running program for all frogs
 */
  void pauseProgram() {
    Logging.logEvent("pause-${name}-program");
    for (Frog frog in frogs.agents) {
      frog.program.pause();
    }
  }
  
  
/**
 * Halts all frogs and restarts their programs
 */
  void stopProgram() {
    for (Frog frog in frogs.agents) {
      frog.program.restart();
    }
  }

  
/**
 * Restart to single frog on home lilypad
 */
  void restartProgram() {
    Logging.logEvent("restart-${name}-program");
    for (Frog frog in frogs.agents) {
      frog.die();
    }
    addHomeFrog().pulse();
    bug.reset();
    scoreboard.reset();
  }
  
  
  void removeAllBlocks() {
    Logging.logEvent("trash-${name}-program");
    super.removeAllBlocks();
  }

  
/**
 * Is there a frog still running a program?
 */
  bool isProgramRunning() {
    bool running = false;
    for (Frog frog in frogs.agents) {
      if (frog.program.isRunning) running = true;
    }
    return running;
  }
  
  
/**
 * Creates a simple starting program so that there's something that can be run
 */
  void buildDefaultProgram() {
    Block block = new Block(this, 'hop');
    block.x = start.x;
    block.y = start.y - 300.0;
    addBlock(block);
    snapTogether(block);
    block.inserted = true;
  }
  
  
/**
 * Animate the blocks and return true if any of the blocks changed
 */
  bool animate() {
    bool refresh = false;
    
    frogs.removeDead();
    
    if (super.animate()) refresh = true;
    
    if (frogs.animate()) refresh = true;
    
    if (frogs.length == 0) {
      restartProgram();
    }

    bool r = isProgramRunning();
    if (r != running) refresh = true;
    running = r;
    
    if (scoreboard.animate()) refresh = true;

    return refresh;
  }
  
  
/**
 * Called by pond to trace the execution of the program for the target frog
 */
  void traceExecution(Frog frog) {
    if (frog.label != null) {
      ctx.save();
      double tx = worldToObjectX(frog.x, frog.y);
      double ty = worldToObjectY(frog.x, frog.y);
      ctx.textBaseline = 'top';
      ctx.textAlign = 'center';
      ctx.fillStyle = 'white';
      ctx.font = '200 16px sans-serif';
      ctx.fillText(frog.label, tx, ty + 52);
      ctx.restore();
    }
    bug.target = frog.program.curr;
  }
  
  
  void captureBug(Beetle bug) {
    scoreboard.captureBug(bug);
    Logging.logEvent("${name}-capture-bug", "${bug.color}-bug");
  }  
  
  
  void draw() {
    ctx.save();
    {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      frogs.draw(ctx);
      
      super.draw();
      
      xform.transformContext(ctx);
      
      Frog target = getFocalFrog();
      if (target != null) traceExecution(target);
      
      scoreboard.draw(ctx);
    }
    ctx.restore();
  }
  
  
  void _initMenu() {
    Block block;
    Parameter param;
    
    // HOP block
    menu.addBlock(new Block(this, 'hop'), 3);
    
    // CHIRP block
    menu.addBlock(new Block(this, 'chirp'), 2);
    
    // EAT block
    menu.addBlock(new Block(this, 'eat'), 2);
    
    // TURN block
    if (SHOW_TURN_BLOCK) {
      block = new Block(this, 'turn');
      block.param = new Parameter(block);
      block.param.values = [ -90, -75, -60, -45, -30, -15, 'random', 15, 30, 45, 60, 75, 90 ];
      block.param.index = 6;
      menu.addBlock(block, 2);
    }
    else {
      menu.addBlock(new Block(this, 'left'), 2);
      menu.addBlock(new Block(this, 'right'), 2);
    }
    
    menu.addBlock(new Block(this, 'spin'), 2);
    
    // HATCH block
    block = new Block(this, 'hatch');
    block.color = '#b67196';
    menu.addBlock(block, 1);
    
    // DIE block
    if (SHOW_DIE_BLOCK) {
      block = new Block(this, 'die');
      block.color = '#b67196';
      menu.addBlock(block, 1);
    }
    
    // IF block
    IfElseBlock ifblock = new IfElseBlock(this);
    ifblock.param = new Parameter(ifblock);
    ifblock.param.centerX = ifblock.width - 35;
    ifblock.param.values = [ 'see-bug?', 'at-water?', 'blocked?' ];
    menu.addBlock(ifblock, 2);
    
    // REPEAT block
    menu.addBlock(new RepeatBlock(this), 2);
  }
}

class StandardFrogWorkspace extends FrogWorkspace{

    
  StandardFrogWorkspace(FrogPond pond, int width, int height, String name) : super(pond, width, height, name){
    
    // menu bar
    _initMenu();
    

    }
}

class TangibleFrogWorkspace extends FrogWorkspace{

    
    TangibleFrogWorkspace(FrogPond pond, int width, int height, String name) : super(pond, width, height, name){
      showBlocks = false;
      
    }
    
    void playProgram() {
      removeAllBlocks();
      if(tangibleList != null){
        tangibleList.clear();
      }
      print("ws-send: hello?");
      ws.send("hello?");
      Timer delayRead = new Timer(new Duration(milliseconds: 100), playProgramDelay); 
      

    }
    
    void playProgramDelay(){
      if(newList != true){
        Timer delayRead = new Timer(new Duration(milliseconds: 100), playProgramDelay);
        return;
      }
      else{
        print(tangibleList);
        addTangibleBlocks(tangibleList);
        Logging.logEvent("play-${name}-program");
        if (frogs.length == 0) addHomeFrog();
        for (Frog frog in frogs.agents) {
          frog.program.play();
        }
        newList = false;
      }
    }
    
    void addTangibleBlocks(List<String> blocks){
      List<Block> newProgram = new List<Block>();
      for(String blockName in blocks){
        if(blockName == 'hop' || blockName == 'chirp' || blockName == 'eat' || blockName == 'left' || blockName == 'right' || blockName == 'spin'|| blockName == 'hatch'){
          print("adding block ${blockName}");
          Block temp = new Block(this, blockName);
          newProgram.add(temp);
        }
        else if(blockName == 'ifseebug'||blockName== 'repeat5'||blockName== 'repeat3'){
          
        }
        else if(blockName == 'repeatForever'){
//          Block temp = new RepeatBlock(this);
//          temp.param = 
        }
        else if(blockName == 'noType'){
          
        }
        else{
          constructProgram(newProgram);
          return;
        }
          
      }
      constructProgram(newProgram);
      return;
    }
    
    void constructProgram(List<Block> newProgram){
      for(int i = 0; i < newProgram.length; i++){
        if(i == 0){
          start.next = newProgram[i];
          newProgram[i].prev = start;
          
        }
        else{
          newProgram[i].prev = newProgram[i-1];
        }
        if(i+1 < newProgram.length){
          newProgram[i].next = newProgram[i+1];
        }
        else return;
      }
      return;
    }
}
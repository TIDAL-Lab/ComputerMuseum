/*
 * Computer History Museum Exhibit
 */
part of ComputerHistory;

class NetTango extends TouchManager {
      
   Model model;
   Toolbar toolbar = null;
   
   int width = 400;
   int height = 400;
   
   // current tick count
   int ticks = 0;
   
   
   //-------------------------------------------
   // Play state
   //   -2 : play backward 2x
   //   -1 : play backward normal speed
   //   0  : paused
   //   1  : play forward normal speed
   //   2  : play forward 2x
   //   4  : play forward 4x ....
   //-------------------------------------------
   int play_state = 0; 

   
   NetTango(this.model) {
   }
   
   
/* 
 * Show the toolbar on the screen
 */
  void showToolbar() {
    toolbar = new Toolbar(this);
  }
 
 
/*
 * Restart the simulation
 */
  void restart() {
    pause();
    ticks = 0;
    model.setup();
    draw();
  }

   
/*
 * Tick: advance the model, animate, and repaint
 */
  void tick() {
    if (play_state != 0) {
      for (int i=0; i<play_state; i++) {
        ticks++;
        animate();
      }
      draw();
      window.setTimeout(tick, 20);
    }
  }
   
   
/*
 * Start the simulation
 */
  void play(num speedup) {
    play_state = speedup;
    tick();
  }
   

/*
 * Pause the simulation
 */
  void pause() {
    play_state = 0;
  }
   
   
/*
 * Speed up the simulation
 */
  void fastForward() {
    if (play_state < 16 && play_state > 0) {
      play_state *= 2;
    } else if (play_state == 0) {
      play(1);
    } else {
      play_state = 1;
    }
  }
   
   
/*
 * Step forward 1 tick 
 */
  void stepForward() {
    pause();
    ticks++;
    animate();
    draw();
  }
   
   
/*
 * Toggle fullscreen mode
 */
  void fullscreen() {
    restart();
    model.resize(0, 0, window.innerWidth, window.innerHeight);
    draw();
  }
   
   
  void partscreen() {
    restart();
    model.resize(50, 50, width, height);
    draw();
  }
   
   
  void animate() {
    model.tick(play_state);
  }


  void draw() {
    model.draw();
    if (toolbar != null) toolbar.draw();
  }
}

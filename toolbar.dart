/*
 * Computer History Museum Exhibit
 */
part of ComputerHistory;

class Toolbar implements Touchable {

   // list of buttons contained in the toolbar
   List<Button> buttons;
   
   // drawing context 
   var ctx;
   
   // for dispatching touch events
   Button target = null;
   
   // used to control the model
   NetTango app;
   
   // toolbar dimensions
   int width, height;
   
   Button playButton;
   Button pauseButton;
   //Button scrubButton;
   Button fullButton;
   Button partButton;
   //protected int scrubMax;
   //protected boolean fullscreen = false;

   
  Toolbar(this.app) {
    TouchLayer layer = new TouchLayer("toolbar");
    TouchManager.addLayer(layer);
    layer.addTouchable(this);
    
    ctx = layer.context;
    width = layer.width;
    height = layer.height;

    buttons = new List<Button>();

    int w = width;
    int h = height;
    int bw = 40;
    int bh = 30;
    int bx = 0;
    int by = 8;

    Button button;

    button = new Button(w~/2 - bw~/2 + 3, by, "play");
    button.setImage("images/play.png");
    buttons.add(button);
    button.onClick = doPlay;
    button.onDown = repaint;
    button.enabled = true;
    button.visible = true;
    playButton = button;
    
    button = new Button(w~/2 - bw~/2 + 3, by, "pause");
    button.setImage("images/pause.png");
    button.onClick = doPause;
    button.onDown = repaint;
    button.visible = false;
    button.enabled = false;
    buttons.add(button);
    pauseButton = button;
    bx += bw;
    
    button = new Button(w~/2 + bx - bw~/2, by, "fastforward");
    button.setImage("images/fastforward.png");
    button.onDown = repaint;
    button.onClick = doFastForward;
    buttons.add(button);
    
    button = new Button(w~/2 - bw~/2 - bx, by, "rewind");
    button.setImage("images/rewind.png");
    button.onDown = repaint;
    buttons.add(button);
    bx += bw;
    
    button = new Button(w~/2 + bx - bw~/2, by, "stepforward");
    button.setImage("images/stepforward.png");
    button.onDown = repaint;
    button.onClick = doStepForward;
    buttons.add(button);
    
    button = new Button(w~/2 - bx - bw~/2, by, "stepback");
    button.setImage("images/stepback.png");
    button.onDown = repaint;
    buttons.add(button);
    
    bx = 12;
    button = new Button(bx, by, "restart");
    button.setImage("images/restart.png");
    button.onDown = repaint;
    button.onClick = doRestart;
    buttons.add(button);
    
    bx = w - 8 - bw;
    button = new Button(bx, by, "fullscreen");
    button.setImage("images/fullscreen.png");
    button.visible = true;
    button.enabled = true;
    buttons.add(button);
    button.onDown = repaint;
    button.onClick = doFullscreen;
    fullButton = button;
    
    button = new Button(bx, by, "partscreen");
    button.setImage("images/partscreen.png");
    button.visible = false;
    button.enabled = false;
    buttons.add(button);
    button.onDown = repaint;
    button.onClick = doPartscreen;
    partButton = button;
    
    bw = 250;
    bh = 10;
    bx = w~/2 - bw~/2;
    by = h - bh~/2 - 10;
    /*
          button = new Button(bx - 10, by - 10, 20, 20, "ball");
          button.setImage("/images/ball.png");
          buttons.add(button);
          scrubButton = button;
    */
    window.setTimeout(draw, 200);
      
    TouchManager.addTouchable(this);
  }
   
   
   void repaint(var act) {
      draw();
   }
   
   
   void doPlay(var a) {
      playButton.enabled = false;
      playButton.visible = false;
      pauseButton.enabled = true;
      pauseButton.visible = true;
      app.play(1);
      draw();
   }
   
   
   void doPause(var a) {
     playButton.enabled = true;
     playButton.visible = true;
     pauseButton.enabled = false;
     pauseButton.visible = false;
     app.pause();
     draw();     
   }
   
   
   void doRestart(var a) {
     playButton.enabled = true;
     playButton.visible = true;
     pauseButton.enabled = false;
     pauseButton.visible = false;
     app.restart();
     draw();      
   }
   
   
   void doFastForward(var a) {
     playButton.enabled = false;
     playButton.visible = false;
     pauseButton.enabled = true;
     pauseButton.visible = true;
     app.fastForward();
     draw();      
   }
   
   
   void doStepForward(var a) {
      playButton.enabled = true;
      playButton.visible = true;
      pauseButton.enabled = false;
      pauseButton.visible = false;
      app.stepForward();
      draw();      
   }
   
   
   void doFullscreen(var a) {
      partButton.enabled = true;
      partButton.visible = true;
      fullButton.enabled = false;
      fullButton.visible = false;
      app.fullscreen();
      draw();
   }
   
   
   void doPartscreen(var a) {
     partButton.enabled = false;
     partButton.visible = false;
     fullButton.enabled = true;
     fullButton.visible = true;
     app.partscreen();
     draw();     
   }

  void draw() {
      
    int w = width;
    int h = height;
    ctx.clearRect(0, 0, width, height);
     
    for (var button in buttons) {
      button.draw(ctx);
    }
      
    //---------------------------------------------
    // Draw speedup
    //---------------------------------------------
    ctx.font = "18px sans-serif";
    ctx.fillStyle = "white";
    ctx.textBaseline = "bottom";
    ctx.textAlign = "left";
    int pstate = app.play_state.abs();
    if (pstate > 1) {
      ctx.fillText("x$pstate", w~/2 - 167, h - 10);
    } 
    
    //---------------------------------------------
    // Draw tick counter
    //---------------------------------------------
    int ticks = app.ticks;
    ctx.font = "12px sans-serif";
    ctx.fillStyle = "white";
    ctx.textAlign = "right";
    ctx.fillText("tick: $ticks", w - 15, h - 12);
    
    //---------------------------------------------
    // Draw the scrub bar
    //---------------------------------------------
    int bw = 250;
    int bh = 10;
    int bx = w~/2 - bw~/2;
    int by = h - bh - 10;
    ctx.fillStyle = "rgba(0, 0, 0, 0.4)";
    ctx.fillRect(bx, by, bw, bh);
    
    /*
    SimStream stream = model.getStream();
    float scale = (float)bw / scrubMax;
    int min = (int)(stream.getMinIndex() * scale);
    int max = (int)(stream.getMaxIndex() * scale);
    
    g.setColor(Color.LIGHT_GRAY);
    g.fillRect(bx + min, by, max - min, bh);
    
    g.setColor(Color.GRAY);
    g.drawRect(bx, by, bw, bh);
    */
    
    //---------------------------------------------
    // Move the play head
    //---------------------------------------------
    /*
    int index = model.getPlayHead();
    bx += (int)(index * scale);
    by += bh / 2;
    scrubButton.reshape(bx - 10, by - 10, 20, 20);
    */
  }

   /*
   boolean flip = false;
   protected void movePlayHead(int delta) {
      if (flip && Math.abs(delta) == 1) return;
      if (Math.abs(delta) > 1) delta /= 2;
      SimStream stream = model.getStream();
      int index = model.getPlayHead() + delta;
      if (!model.isLoaded()) return;
      while (index > stream.getMaxIndex()) {
         model.tick();
      }
      model.setPlayHead(index);
      if (index <= stream.getMinIndex()) pstate = 0;
   }
   */

   
  void animate() {
      /*
      flip = !flip;
      SimStream stream = model.getStream();

      // Adjust size of scrub bar if necessary
      int index = model.getPlayHead();
      if (stream.getMaxIndex() == 0) {
         scrubMax = stream.getCapacity();
      } else if (index * 1.15f > scrubMax) {
         scrubMax *= 2;
      }
      
      // fill the simulation buffer
      if (!stream.isBufferFull()) {
         //model.tick();
      }
      
      // play or fastforward
      movePlayHead(pstate);
      */
  }
/*
   public void onClick(Button button) {
      Main app = Main.instance;
      if ("play".equals(button.getAction())) {
         this.pstate = 1;
      } else if ("pause".equals(button.getAction())) {
         this.pstate = 0;
      } else if ("restart".equals(button.getAction())) {
         model.setup();
         app.layout(app.getWidth(), app.getHeight());
         this.pstate = 0;
      } else if ("fastforward".equals(button.getAction())) {
         if (pstate <= 0 || pstate >= 8) {
            pstate = 1;
         } else if (pstate > 0 && pstate < 8) {
            pstate *= 2;
         } 
      } else if ("rewind".equals(button.getAction())) {
         if (pstate >= 0 || pstate <= -8) {
            pstate = -1;
         } else if (pstate < 0 && pstate > -8) {
            pstate *= 2;
         }
      } else if ("stepforward".equals(button.getAction())) {
         pstate = 0;
         movePlayHead(1);
      } else if ("stepback".equals(button.getAction())) {
         pstate = 0;
         movePlayHead(-1);
      } else if ("fullscreen".equals(button.getAction())) {
         fullButton.setVisible(false);
         fullButton.setEnabled(false);
         partButton.setVisible(true);
         partButton.setEnabled(true);
         this.fullscreen = true;
         app.enterFullscreen();
         
      } else if ("partscreen".equals(button.getAction())) {
         fullButton.setVisible(true);
         fullButton.setEnabled(true);
         partButton.setVisible(false);
         partButton.setEnabled(false);
         this.fullscreen = false;
         app.exitFullscreen();
      }
      
      
      playButton.setEnabled(pstate == 0);
      playButton.setVisible(pstate == 0);
      pauseButton.setEnabled(pstate != 0);
      pauseButton.setVisible(pstate != 0);
   }
   */

   
   bool containsTouch(Contact event) {
      num tx = event.touchX;
      num ty = event.touchY;
      return (tx >= 0 && ty >= 0 && tx <= width && ty <= height);
   }
   

   bool touchDown(Contact event) {
      for (var b in buttons) {
         if (b.containsTouch(event) && b.enabled && b.visible) {
            target = b;
            target.touchDown(event);
            return true;
         }
      }
      return false;
   }
   
   
   void touchUp(Contact event) {
      if (target != null) {
         target.touchUp(event);
         target = null;
      }
   }
   

   void touchDrag(Contact event) {
      if (target != null) {
         target.touchDrag(event);
      }
   }
   

   void touchSlide(Contact event) { }
}
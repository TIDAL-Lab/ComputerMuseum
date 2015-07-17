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
part of NetTango;

  
/**
 * Visual toolbar with play, pause, restart buttons
 */
class Toolbar {

  /* Link back to the code workspace that this bar controls */
  CodeWorkspace workspace;
  
  /* Dimensions of the toolbar */
  num x, y, w, h;

  /* Special buttons */  
  Button play, pause, btarget = null;
  
  /* Toolbar buttons */  
  List<Button> buttons = new List<Button>();
  
  /* Representative frog */
  FrogButton froggy;
  
  /* Animates the show code dialog */
  Tween tween = new Tween();
  
  /* Show code alpha value */
  double alpha = 0.0;
  
  
  Toolbar(this.workspace, this.x, this.y, this.w, this.h) {
    froggy = new FrogButton(x + 10, y - 4, this);
    
    num bx = x + 98;
    num by = y + h/2 - 18;
    int bspace = 58;
    
    buttons.add(new Button(bx, by, workspace, "images/toolbar/play.png", () {
      workspace.playProgram(); }));
    
    buttons.add(new Button(bx, by, workspace, "images/toolbar/pause.png", () {
      workspace.pauseProgram(); }));
    
    buttons.add(new Button(bx + bspace, by, workspace, "images/toolbar/restart.png", () {
      workspace.restartProgram(); }));
    /*
    buttons.add(new Button(bx + bspace * 2, by, workspace, "images/toolbar/trash.png", () {
      workspace.removeAllBlocks(); }));
    */
    buttons.add(new Button(bx + bspace * 2, by, workspace, "images/toolbar/help.png", () {
      workspace.showHideHelp(); }));
    
    buttons.add(new Button(workspace.width - 210, by, workspace, "images/toolbar/info.png", () {
      workspace.showHideCredits(); }));
    
    play = buttons[0];
    pause = buttons[1];
    pause.visible = false;
    
    // add buttons as touchable objects to the workspace
    workspace.addTouchable(froggy);
    for (Button b in buttons) {
      workspace.addTouchable(b);
    }
  }
  
  
  bool animate() {
    bool refresh = false;
    if (tween.isTweening()) {
      tween.animate();
      refresh = true;
    }
    if (play.animate()) refresh = true;
    return refresh;
  }
  
  
  void pulsePlayButton() {
    play.pulse();
  }

  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save();
    {
      //---------------------------------------------
      // toolbar outline
      //---------------------------------------------
      /*
      ctx.fillStyle = '#3e5d64';
      ctx.strokeStyle = '#223333';
      ctx.lineWidth = 3;
      
      ctx.beginPath();
      ctx.moveTo(x + w - 10, y + h);
      ctx.bezierCurveTo(x + w, y - 70, x + w/2, y + 20, x - 6, y - 5);
      ctx.lineTo(x - 6, y + h);
      ctx.fill();
      ctx.stroke();
      */
      //---------------------------------------------
      // representative frog
      //---------------------------------------------      
      froggy.draw(ctx);
      
      //---------------------------------------------
      // toolbar buttons
      //---------------------------------------------
      play.visible = !workspace.isProgramRunning();
      pause.visible = workspace.isProgramRunning();
      buttons.forEach((button) => button.draw(ctx));
      
      //---------------------------------------------
      // show code dialog
      //---------------------------------------------
      drawShowCode(ctx);
    }
    ctx.restore();
  }
  
  void drawShowCode(CanvasRenderingContext2D ctx) {
    Frog focal = workspace.getFocalFrog();
    if (focal == null) return;
      
    ctx.font = '600 15px Monaco, monospace';
    ctx.textBaseline = 'top';
    ctx.textAlign = 'left';

    // figure out text dimensions      
    var lines = focal.program.compile().split('\n');
    int margin = 25;
    int dh = lines.length * 20 + margin * 2;
    int dx = 20;
    int dy = y - 25 - dh;
    int dw = margin * 2;

    // dynamically size width of the dialog      
    for (int i=0; i<lines.length; i++) {
      dw = max(dw, ctx.measureText(lines[i]).width + margin * 2);
    }
    
    ctx.fillStyle = "rgba(255, 255, 255, $alpha)";
    ctx.strokeStyle = "rgba(0, 0, 0, $alpha)";
    ctx.lineWidth = 2;
    drawBubble(ctx, dx, dy, dw, dh, margin);
 
    // draw each line     
    ctx.fillStyle = "rgba(0, 0, 0, $alpha)";
    for (int i=0; i<lines.length; i++) {
      ctx.fillText(lines[i], dx + margin, dy + margin * 1.5 + i * 20);
    }
  }
  

  void showCode() {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.duration = 5;
    tween.addControlPoint(0.0, 0.0);
    tween.addControlPoint(0.9, 1.0);
    tween.ontick = ((value) => alpha = value);
  }
  
  
  void hideCode() {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.duration = 20;
    tween.addControlPoint(0.9, 0.0);
    tween.addControlPoint(0.8, 0.5);
    tween.addControlPoint(0.0, 1.0);
    tween.ontick = ((value) => alpha = value);
  }
}

class FrogButton extends Touchable {
  
  ImageElement frog = new ImageElement();
  num x, y, w, h;
  Toolbar toolbar;

  
  FrogButton(this.x, this.y, this.toolbar) {
    frog.src = "images/${toolbar.workspace.name}frog.png";
    frog.onLoad.listen((e) {
      w = frog.width * 0.7;
      h = frog.height * 0.7;
    });
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    if (w != null && h != null) {
      ctx.drawImageScaled(frog, x, y, w, h);
    }
  }
  
  
  bool containsTouch(Contact c) {
    return(c.touchX >= x &&
           c.touchY >= y &&
           c.touchX <= x + w &&
           c.touchY <= y + h);
  }
  
  bool touchDown(Contact c) {
    toolbar.showCode();
    return true;
  }
  
  void touchUp(Contact c) {
    toolbar.hideCode();
  }
  void touchCancel(Contact c) { }
  void touchDrag(Contact c) { }
  void touchSlide(Contact c) { }
}


class Button extends Touchable {
  
  num x, y, w, h;
  ImageElement img = new ImageElement();
  bool down = false;
  bool over = false;
  bool visible = true;
  Function action = null;
  Tween tween = new Tween();
  double _pulse = 1.0;
  CodeWorkspace workspace;
  
  
  Button(this.x, this.y, this.workspace, String src, this.action) {
    img.src = src;
    img.onLoad.listen((e) {
      w = img.width;
      h = img.height;
    });
  }
  
  int get width => w;
  
  int get height => h;

  
  void pulse() {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.delay = 5;
    tween.duration = 30;
    tween.repeat = 2;
    tween.onstart = (() => _pulse = 1.0 );
    tween.onend = (() => _pulse = 1.0 );
    tween.ondelta = ((value) {
      _pulse += value;
    });
    tween.addControlPoint(1.0, 0.0);
    tween.addControlPoint(0.3, 0.5);
    tween.addControlPoint(1.0, 1.0);
  }
  
  
  bool animate() {
    if (tween.isTweening()) {
      tween.animate();
      return true;
    } else {
      return false;
    }
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    if (visible) {
      num ix = (down && over) ? x + 2 : x;
      num iy = (down && over) ? y + 2 : y;
      ctx.globalAlpha = _pulse;
      ctx.drawImage(img, ix, iy);
      ctx.globalAlpha = 1.0;
    }
  }
  
  
  bool containsTouch(Contact c) {
    return (visible &&
            c.touchX >= x &&
            c.touchY >= y &&
            c.touchX <= x + w &&
            c.touchY <= y + h);
  }
  
  
  bool touchDown(Contact c) {
    down = true;
    over = true;
    workspace.draw();
    return visible;
  }
  
  
  void touchUp(Contact c) {
    if (down && over && visible && action != null) {
      Function.apply(action, []);
    }
    down = false;
    over = false;
  }
  
  
  void touchCancel(Contact c) {
    down = false;
    over = false;
  }
  
  
  void touchDrag(Contact c) {
    if (down && visible) {
      over = containsTouch(c);
      workspace.draw();
    }
  }

  
  void touchSlide(Contact c) { }
}

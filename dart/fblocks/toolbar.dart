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
part of ComputerHistory;

  
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
  
  ImageElement frog = new ImageElement();
  
  List<Button> buttons = new List<Button>();
  
  
  Toolbar(this.workspace, this.x, this.y, this.w, this.h) {
    frog.src = "images/${workspace.color}frog.png";
    
    int bx = x + 95;
    int by = y + h/2 - 15;
    int bspace = 43;
    
    buttons.add(new Button(bx, by, "images/toolbar/play.png", () {
      workspace.playProgram(); }));
    
    buttons.add(new Button(bx, by, "images/toolbar/pause.png", () {
      workspace.pauseProgram(); }));
    
    buttons.add(new Button(bx + bspace, by, "images/toolbar/restart.png", () {
      workspace.restartProgram(); }));
    
    buttons.add(new Button(bx + bspace * 2, by, "images/toolbar/trash.png", () {
      workspace.removeAllBlocks(); }));
    
    play = buttons[0];
    pause = buttons[1];
    pause.visible = false;
    
    // add buttons as touchable objects to the workspace
    for (Button b in buttons) {
      workspace.addTouchable(b);
    }
  }
  
  
  bool animate() {
    return play.animate();
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
      ctx.fillStyle = '#3e5d64';
      ctx.strokeStyle = '#223333';
      ctx.lineWidth = 3;
      
      ctx.beginPath();
      ctx.moveTo(x + 230, y + h);
      ctx.bezierCurveTo(x + 250, y - 50, x + 160, y + 10, x - 6, y - 5);
      ctx.lineTo(x - 6, y + h);
      ctx.fill();
      ctx.stroke();
      
      //---------------------------------------------
      // representative frog
      //---------------------------------------------      
      int iw = (frog.width * 0.7).toInt();
      int ih = (frog.height * 0.7).toInt();
      int ix = x + 10;
      int iy = y + 2;
      ctx.drawImageScaled(frog, ix, iy, iw, ih);
      
      //---------------------------------------------
      // toolbar buttons
      //---------------------------------------------
      play.visible = !workspace.running;
      pause.visible = workspace.running;
      buttons.forEach((button) => button.draw(ctx));
    }
    ctx.restore();
  }
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
  
  
  Button(this.x, this.y, String src, this.action) {
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
      int ix = (down && over) ? x + 2 : x;
      int iy = (down && over) ? y + 2 : y;
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
    return visible;
  }
  
  
  void touchUp(Contact c) {
    if (down && over && visible && action != null) {
      Function.apply(action, []);
    }
    down = false;
    over = false;
  }
  
  
  void touchDrag(Contact c) {
    if (down && visible) {
      over = containsTouch(c);
    }
  }

  
  void touchSlide(Contact c) { }
}

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

  
/**
 * Visual programming block
 */
class Menu implements Touchable {

  CodeWorkspace workspace;
  
  num x, y, w, h;
  
  List<Block> blocks = new List<Block>();
  
  Block target = null;
  
  Button play, pause, btarget = null;
  
  ImageElement frog = new ImageElement();
  
  List<Button> buttons = new List<Button>();
  
  
  Menu(this.workspace, this.x, this.y, this.w, this.h) {
    frog.src = "images/${workspace.color}frog.png";
    play = new Button(x + 95, y + h/2 - 15, "images/toolbar/play.png", () {
      workspace.playProgram(); });
    
    pause = new Button(x + 95, y + h/2 - 15, "images/toolbar/pause.png", () {
      workspace.pauseProgram(); });
    pause.visible = false;
    
    buttons.add(play);
    buttons.add(pause);
    buttons.add(new Button(x + 130, y + h/2 - 15, "images/toolbar/restart.png", () {
      workspace.restartProgram(); }));
    buttons.add(new Button(x + 165, y + h/2 - 15, "images/toolbar/fastforward.png", () {
      workspace.fastForwardProgram(); }));
    buttons.add(new Button(x + 200, y + h/2 - 15, "images/toolbar/trash.png", () {
      workspace.removeAllBlocks(); }));
  }
  
  
  void addBlock(Block block) {
    blocks.add(block);
  }
  
  
  bool overlaps(Block block) {
    return (block.centerY >= y);
  }
  
  
  void animate() {
    play.animate();
  }
  
  
  void pulsePlayButton() {
    play.pulse();
  }

  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save();
    {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
      ctx.fillRect(x, y, w, h);

      ctx.fillStyle = '#3e5d64';
      ctx.strokeStyle = '#223333';
      ctx.lineWidth = 3;
      
      ctx.beginPath();
      ctx.moveTo(x + 250, y + h);
      ctx.bezierCurveTo(x + 270, y - 50, x + 160, y + 10, x - 6, y - 5);
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
      
      //---------------------------------------------
      // programming blocks
      //---------------------------------------------
      ix += 260;
      iy = y + h/2;
      
      for (Block block in blocks) {
        block.x = ix.toDouble();
        block.y = iy.toDouble() - block.height / 2;
        block.inMenu = true;
        block.draw(ctx);
        ix += block.width + 10;
      }
    }
    ctx.restore();
  }
  
  
  bool containsTouch(Contact c) {
    for (Block block in blocks) {
      if (block.containsTouch(c)) {
        return true;
      }
    }
    for (Button button in buttons) {
      if (button.containsTouch(c)) {
        return true;
      }
    }
    return false;
  }
  
  
  bool touchDown(Contact c) {
    for (Block block in blocks) {
      if (block.containsTouch(c)) {
        target = block.clone();
        workspace.addBlock(target);
        target.move(-2, -8);
        target.touchDown(c);
        return true;
      }
    }
    
    for (Button button in buttons) {
      if (button.containsTouch(c)) {
        btarget = button;
        btarget.touchDown(c);
        workspace.draw();
        return true;
      }
    }
    
    return false;
  }
  
  
  void touchUp(Contact c) {
    if (target != null) {
      target.touchUp(c);
    }
    else if (btarget != null) {
      btarget.touchUp(c);
      workspace.draw();
    }
    target = null;
    btarget = null;
  }
  
  
  void touchDrag(Contact c) {
    if (target != null) {
      target.touchDrag(c);
    }
    else if (btarget != null) {
      btarget.touchDrag(c);
      workspace.draw();
    }
  }
  
  
  void touchSlide(Contact c) { }
}


class Button {
  
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
}

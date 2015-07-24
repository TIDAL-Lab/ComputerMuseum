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
    int bspace = 50;
    
    buttons.add(new Button(bx, by, workspace, "images/toolbar/play.png", () {
      workspace.playProgram(); }));
    
    buttons.add(new Button(bx, by, workspace, "images/toolbar/pause.png", () {
      workspace.pauseProgram(); }));
    
    Button restart = new Button(bx + bspace, by, workspace, "images/toolbar/restart.png", null);

    restart.menu = new PopupMenu(restart);
    restart.menu.addOption("Clear Program", () => workspace.removeAllBlocks());
    restart.menu.addOption("Clear Scoreboard", () => workspace.clearScoreboard());
    restart.menu.addOption("Restart Frogs", () => workspace.restartProgram());
    workspace.addTouchable(restart.menu);
    buttons.add(restart);

    /*
    buttons.add(new Button(bx + bspace * 2, by, workspace, "images/toolbar/trash.png", () {
      workspace.removeAllBlocks(); }));
    */
    buttons.add(new Button(bx + bspace * 2, by, workspace, "images/toolbar/help.png", () {
      workspace.showHideHelp(); }));
    
    buttons.add(new Button(bx + bspace * 3, by, workspace, "images/toolbar/info.png", () {
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
    for (Button button in buttons) {
      if (button.animate()) refresh = true;
    }
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
    Program program = new Program(workspace);
      
    ctx.font = '600 15px Monaco, monospace';
    ctx.textBaseline = 'top';
    ctx.textAlign = 'left';

    // figure out text dimensions      
    var lines = program.compile().split('\n');
    num margin = 25;
    num dh = lines.length * 20 + margin * 2;
    num dx = 20;
    num dy = y - 25 - dh;
    num dw = margin * 2;

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


  void closeAllMenus() {
    for (Button button in buttons) { 
      button.closeMenu();
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
  
  num x, y, w = 0, h = 0;
  ImageElement img = new ImageElement();
  bool down = false;
  bool over = false;
  bool visible = true;
  Function action = null;
  Tween tween = new Tween();
  double _pulse = 1.0;
  CodeWorkspace workspace;

  // optional popup menu
  PopupMenu menu = null;
  
  
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


  void closeMenu() {
    if (menu != null) {
      menu.hideMenu();
    }
  }
  
  
  bool animate() {
    bool refresh = false;
    if (tween.isTweening()) {
      tween.animate();
      refresh = true;
    } 
    if (menu != null && menu.animate()) {
      refresh = true;
    }
    return refresh;
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    if (visible) {
      num ix = (down && over) ? x + 2 : x;
      num iy = (down && over) ? y + 2 : y;
      ctx.globalAlpha = _pulse;
      ctx.drawImage(img, ix, iy);
      ctx.globalAlpha = 1.0;

      if (menu != null && menu.isOpen) {
        menu.draw(ctx);
      }
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
    if (menu != null) {
      menu.showHideMenu();
      menu.touchDown(c);
    }
    workspace.draw();
    return visible;
  }
  
  
  void touchUp(Contact c) {
    if (menu == null && down && over && visible && action != null) {
      Function.apply(action, []);
    }
    else if (menu != null && menu.isOverMenu(c)) {
      menu.touchUp(c);
    }
    down = false;
    over = false;
    workspace.draw();
  }
  
  
  void touchCancel(Contact c) {
    down = false;
    over = false;
  }
  
  
  void touchDrag(Contact c) {
    if (menu != null) {
      menu.touchDrag(c);
    }
    if (down && visible) {
      over = containsTouch(c);
      workspace.draw();
    }
  }

  
  void touchSlide(Contact c) { }
}


class PopupMenu implements Touchable {

  Button button;

  int _index = -1;
  
  num _lastX = 0.0, _lastY = 0.0;
  
  // location of callout menu
  num _menuX = 0, _menuY = 0, _menuW = 0, _menuH = 0;
  
  List<String> values = new List<String>();
  List<Function> actions = new List<Function>();
  
  String _color = 'white'; //'#777';
  
  String _textColor = 'blue'; //'white';
  
  bool _dragging = false;  // is a finger / mouse dragging on the screen?

  bool _down = false;  // is a finger / mouse down on the screen?

  bool _menuOpen = false;  // is the parameter menu open

  Tween tween = new Tween();

  double _pulse = 1.0;
  double _alpha = 1.0;
  bool _pulsing = false;
  

  PopupMenu(this.button);

  bool get isOpen => _menuOpen;
  

  void addOption(String value, Function action) {
    values.add(value);
    actions.add(action);
  }


  void showMenu() {
    _alpha = 0.0;
    _menuOpen = true;
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.duration = 5;
    tween.onstart = (() => _alpha = 0.0 );
    tween.ontick = ((value) => _alpha = value );
    tween.addControlPoint(0.0, 0.0);
    tween.addControlPoint(1.0, 1.0);
  }


  void hideMenu() {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.duration = 5;
    tween.ontick = ((value) => _alpha = value );
    tween.addControlPoint(1.0, 0.0);
    tween.addControlPoint(0.0, 1.0);
    tween.onend = (() => _menuOpen = false );
  }


  void selectItem(int index) {
    pulse();
    if (index >= 0 && index < actions.length) {
      Function f = actions[index];
      if (f != null) {
        new Timer(const Duration(milliseconds : 500), () => Function.apply(f, []));
      }
    }
  }


  void showHideMenu() {
    if (isOpen) {
      hideMenu();
    } else {
      showMenu();
    }
  }


  void pulse() {
    tween = new Tween();
    tween.function = TWEEN_SINE2;
    tween.duration = 4;
    tween.repeat = 2;
    tween.onstart = (() {
      _pulse = 1.0;
      _pulsing = true;
    });
    tween.onend = (() { 
      _pulse = 1.0;
      _pulsing = false;
      hideMenu();
    });
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


  num getDisplayWidth(CanvasRenderingContext2D ctx) {
    num w = 20;
    ctx.save();
    {
      for (String s in values) {
        w = max(w, ctx.measureText(s).width + 20);
      }
    }
    ctx.restore();
    return w;
  }


  num getDisplayHeight() {
    return values.length * 40 + 20;
  }

  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save(); 
    ctx.globalAlpha = _alpha;
    ctx.font = '400 17px Nunito, sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';
    
    num margin = 20;
    if (_menuW == 0) {
      _menuW = getDisplayWidth(ctx) + margin * 2;
      _menuH = getDisplayHeight();
    }
    _menuY = button.y - _menuH - 40;
    _menuX = button.x + button.w / 2 - _menuW / 2;
    
    ctx.fillStyle = '#3399aa';
    ctx.strokeStyle = 'white';
    calloutRect(ctx, _menuX, _menuY, _menuW, _menuH, 10, button.x + button.w/2);
    ctx.fill();
    ctx.stroke();
    
    ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
    ctx.strokeStyle = 'rgba(0, 30, 50, 0.4)';
    num mx = _menuX + 5;
    num my = _menuY + 5;
    num mw = _menuW - 10;
    num mh = _menuH - 10;
    roundRect(ctx, mx, my, mw, mh, 8);
    ctx.fill();
    //ctx.stroke();
    
    ctx.fillStyle = '#3399aa';
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.2)';
    
    bool matched = false;
    
    for (int i=0; i<values.length; i++) {
      num ty = my + 5 + 40 * i;
      /*
      if (i == _downIndex) {
        ctx.fillStyle = 'rgba(51, 150, 170, 0.7)';
        ctx.fillRect(mx, ty, mw, 40);
        ctx.fillStyle = 'rgba(255, 255, 255, 0.85)';
      } else {
        ctx.fillStyle = '#3399aa';
      }
      */

      ctx.fillStyle = '#3399aa';
      if (_pulsing && _index == i) {
        ctx.fillStyle = 'rgba(51, 150, 170, $_pulse)';
        ctx.fillRect(mx, ty, mw, 40);
        ctx.fillStyle = 'rgba(255, 255, 255, 0.85)';
      }
      else if (_lastX >= mx && _lastX <= mx + mw &&
          _lastY >= ty && _lastY < ty + 40) {
        //ctx.fillStyle = 'rgba(170, 20, 0, 0.8)';
        ctx.fillStyle = 'rgba(51, 150, 170, 0.7)';
        ctx.fillRect(mx, ty, mw, 40);
        ctx.fillStyle = 'rgba(255, 255, 255, 0.85)';
        _index = i;
        matched = true;
      } 
      ctx.fillText(values[i], mx + 15, ty + 20);
    }
    ctx.restore();
  }
  
  
  void calloutRect(CanvasRenderingContext2D ctx, num x, num y, num w, num h, num r, num cx) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(cx + 20, y + h);
    ctx.lineTo(cx, y + h + 35);
    ctx.lineTo(cx - 20, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();
  }

  
  bool containsTouch(Contact c) {
    return isOverMenu(c);
  }


  bool isOverMenu(Contact c) {
    return (
      _menuOpen && 
      c.touchX >= _menuX && 
      c.touchY >= _menuY && 
      c.touchX <= _menuX + _menuW && 
      c.touchY <= _menuY + _menuH);   
  }
  
  
  void touchUp(Contact c) {
    if (_dragging && isOverMenu(c)) {
      selectItem(_index);
    } else {
      hideMenu();
    }
    _lastX = -1;
    _lastY = -1;
    _dragging = false;
    _down = false;
  }
  
  
  bool touchDown(Contact c) {
    _lastX = c.touchX;
    _lastY = c.touchY;
    _down = true;
    _dragging = true;
    button.workspace.draw();
    return true;
  }
  
  
  void touchDrag(Contact c) {
    _lastX = c.touchX;
    _lastY = c.touchY;
    button.workspace.draw();
  }
  
  
  void touchCancel(Contact c) {
    touchUp(c);
  }

  void touchSlide(Contact c) { }
}


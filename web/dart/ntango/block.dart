/*
 * Computer History Museum Frog Pond
 * Copyright (c) 2014 Michael S. Horn
 * 
 *           Michael S. Horn (michael-horn@northwestern.edu)
 *           Northwestern University
 *           2120 Campus Drive
 *           Evanston, IL 60613
 *           http://tidal.northwestern.edu
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation.
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

const BLOCK_WIDTH = 95.0;
const BLOCK_HEIGHT = 35.0;
const BLOCK_SPACE = 0.0;
const BLOCK_MARGIN = 10.0;


/**
 * Visual programming block
 */
class Block implements Touchable {
  
  /* Used to generate unique block id numbers */
  static int BLOCK_ID = 0;

  /* Link back to the main workspace */
  CodeWorkspace workspace;
  
  /* Unique block ID number */
  int id;
  
  /* Block dimensions */
  double x = 0.0, y = 0.0, _width = 0.0, _height = 0.0, _minwidth = 0.0;
  
  /* For animating blocks */
  double _targetX = null, _targetY = null;
  
  /* Text displayed inside the block */
  String text = 'hop';
  
  /* Block 'type' (usually the same as text) */
  String type = 'hop';
  
  /* CSS color of the block */
  String color = '#3399aa';
  
  /** CSS color of the text */
  String textColor = 'white';

  /** CSS size of the font (e.g. "12px") */
  String textSize = "14px";

  /** CSS outline color of the block */
  String outlineColor = 'rgba(255, 255, 255, 0.3)';
  
  /* Is the block being dragged */
  bool dragging = false;
  
  /* Block that might be inserted after this block */
  Block candidate = null;
  
  /* Next block in the chain */
  Block next;
  
  /* Previous block in the chain */
  Block prev;
  
  /* Parameter for this block? */
  Parameter param = null;
  
  /* Used for dragging the block on the screen */
  double _lastX, _lastY;
  
  /* Flag used to make blocks in the menu slightly smaller */
  bool inMenu = false;
  
  /* Has this been added to the program yet? */
  bool inserted = false;

  /* action this block performs */
  Function action = null;

  
  Block(this.workspace, this.text) {
    id = Block.BLOCK_ID++;
    _width = BLOCK_WIDTH.toDouble();
    _minwidth = BLOCK_WIDTH.toDouble();
    _height = BLOCK_HEIGHT.toDouble();
    type = text;
  }
  
  
  Block clone() {
    Block b = new Block(workspace, text);
    copyTo(b);
    return b;
  }
  
  
  void copyTo(Block other) {
    other.x = x;
    other.y = y;
    other._width = _width;
    other._minwidth = _minwidth;
    other._height = _height;
    other.text = text;
    other.color = color;
    other.textColor = textColor;
    other.outlineColor = outlineColor;
    other.action = action;
    if (hasParam) {
      other.param = param.clone(other);
    }
  }
  
  
  bool get hasParam => param != null;
  
  bool get hasNext => next != null;
  
  bool get hasPrev => prev != null;
  
  bool get isInProgram => hasPrev;
  
  num get width => inMenu ? _minwidth : _width;
  
  num get height => _height;
  
  num get centerX => x + width / 2;
  
  num get centerY => y + height / 2;
  
  num get connectorX => targetX;
  
  num get connectorY => targetY + height + BLOCK_SPACE;
  
  num get targetX {
    if (_targetX != null) return _targetX;
    num tx = hasPrev ? prev.connectorX : x;
    return tx;
  }

  
  num get targetY {
    if (_targetY != null) return _targetY;
    num ty = hasNext ? next.targetY - height - BLOCK_SPACE : y;
    if (candidate != null) {
      ty -= candidate.height + BLOCK_SPACE;
    }
    return ty;
  }
    
  
/**
 * Move a chain of blocks by the given delta value
 */
  void moveChain(num deltaX, num deltaY) {
    x += deltaX;
    y += deltaY;
    if (next != null) next.moveChain(deltaX, deltaY);
  }
  
  
/**
 * Move an individual block by the given delta value
 */
  void move(num deltaX, num deltaY) {
    x += deltaX;
    y += deltaY;
  }
  
  
/**
 * Does this block overlap with 'other'?
 */
  bool overlaps(Block other) {
    return (x <= other.x + other.width + BLOCK_SPACE &&
            other.x <= x + width + BLOCK_SPACE &&
            y <= other.y);
  }
  
  
/**
 * When the program is running, this evaluates this block for a specific frog
 */
  dynamic eval(Program program) {
    var pval = (param == null) ? null : param.value;
    return program.doCommand(text, pval);
  }
  
  
/**
 * Advances the program to the next statement
 */
  Block step(Program program) {
    return next;
  }  

  
/**
 * Converts visual program to text
 */
  String compile(int indent) {
    String tab = "";
    for (int i=0; i<indent; i++) tab += "  ";
    if (param == null) {
      return "${tab}${text}();\n";
    } else {
      return "${tab}${text.replaceAll(' ', '-')}(${param.value});\n";
    }
  }
  
  
  String toString() {
    if (param == null) {
      return "${text}";
    } else {
      return "${text}(${param.value})";
    }
  }
  
    
/**
 * Is it syntactically ok to put this block after the before block?
 */
  bool checkSyntax(Block before) {
    return !(before is EndProgramBlock);
  }
  
  
  bool animate() {
    double dx = targetX - x;
    double dy = targetY - y;
    if (dx.abs() > 1) {
      dx *= 0.3;
    } else {
      _targetX = null;
    }
    if (dy.abs() > 1) {
      dy *= 0.3;
    } else {
      _targetY = null;
    }
    
    if (dx.abs() > 0 || dy.abs() > 0) {
      move(dx, dy);
      return true;
    } else {
      return dragging;
    }
  }
  

/**
 * If the parameter menu is open, close it
 */  
  void closeParameterMenu() {
    if (param != null) {
      param.menuOpen = false;
    }
  } 
  

/**
 * Add target into the chain of blocks after this block
 */
  void insertBlock(Block target) {
    target.next = next;
    target.prev = this;
    if (hasNext) next.prev = target;
    next = target;
    workspace.programChanged();
  }
  
  
/**
 * Draw the block
 */
  void draw(CanvasRenderingContext2D ctx, [ bool disabled = false ]) {
    ctx.globalAlpha = disabled ? 0.3 : 1.0;
    _drawMenuArrow(ctx);
    _resize(ctx);
    _drawOutline(ctx);
    _drawLabel(ctx, x + 12, centerY);
    _drawParam(ctx);
    ctx.globalAlpha = 1.0;
  }
  

  num getTextWdith(CanvasRenderingContext2D ctx) {
    num w = 20;
    ctx.save();
    {
      ctx.font = '300 ${textSize} Nunito, sans-serif';
      w += ctx.measureText(text).width;      
    }
    ctx.restore();
    return w;
  }


  void _resize(CanvasRenderingContext2D ctx) {
    num w = getTextWdith(ctx);
    _minwidth = max(w + 3, BLOCK_WIDTH / 2.25); // for displaying in the menu
    if (param != null && inserted) {
      param.left = w + 10;
      w += param.getDisplayWidth(ctx) + 15;
    }
    _width = max(w, BLOCK_WIDTH);
  }
  
  
  void _drawMenuArrow(CanvasRenderingContext2D ctx) {
    if (workspace.isOverMenu(this) && dragging && !inserted) {
      ctx.fillStyle = 'orange';
      ctx.strokeStyle = 'orange';
      drawLineArrow(ctx, centerX, centerY, centerX, centerY - height, 18);
    }
  }


  void _drawOutline(CanvasRenderingContext2D ctx) {  
    _outline(ctx, x, y, width, height);
    ctx.save();
    {
      /*
      ctx.shadowColor = "#333";
      ctx.shadowBlur = 3;
      ctx.shadowOffsetX = 3;
      ctx.shadowOffsetY = 3;
      */
      ctx.fillStyle = color;
      ctx.strokeStyle = outlineColor;
      ctx.lineWidth = 1.5;
      ctx.fill();
      ctx.stroke();
    }
    ctx.restore();
  }
  
  
  void _drawLabel(CanvasRenderingContext2D ctx, num tx, num ty) {
    var lines = text.split('\n');
    ctx.fillStyle = textColor;
    ctx.font = '300 ${textSize} Nunito, sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';
    //double tx = x + 12;
    //double ty = centerY;

    if (lines.length == 1) {
      ctx.fillText(text, tx, ty);
    } else {
      ctx.fillText(lines[0], tx, ty - 7);
      ctx.fillText(lines[1], tx, ty + 7);
    }
  }
  
  
  void _drawParam(CanvasRenderingContext2D ctx) {
    if (param != null && inserted) {
      param.draw(ctx);
    }
  }

  
  void _outline(CanvasRenderingContext2D ctx, num x, num y, num w, num h) {
    
    num r0 = (prev == null || (prev is ControlBlock && !(prev is EndBlock))) ? 14 : 2;
    num r1 = (next == null || (next is ControlBlock && !(next is BeginBlock))) ? 14 : 2;
    num n = 20;
    
    ctx.beginPath();
    ctx.moveTo(x + r0, y);
    ctx.lineTo(x + n, y);
    ctx.lineTo(x + n + 5, y + 4);
    ctx.lineTo(x + n + 10, y + 4);
    ctx.lineTo(x + n + 15, y);
    ctx.lineTo(x + w, y);
    ctx.lineTo(x + w, y + h);
    ctx.lineTo(x + n + 15, y + h);
    ctx.lineTo(x + n + 10, y + h + 4);
    ctx.lineTo(x + n + 5, y + h + 4);
    ctx.lineTo(x + n, y + h);
    ctx.lineTo(x + r1, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r1);
    ctx.lineTo(x, y + r0);
    ctx.quadraticCurveTo(x, y, x + r0, y);
    ctx.closePath();
  }
  
  
  bool containsTouch(Contact c) {
    double tx = c.touchX;
    double ty = c.touchY;
    return (tx >= x && ty >= y && tx <= x + width && ty <= y + height);
  }
  
  
  bool touchDown(Contact c) {
    dragging = true;
    bool wasInProgram = isInProgram;
    _lastX = c.touchX;
    _lastY = c.touchY;
    
    // remove block from program
    if (hasPrev) prev.next = next;
    if (hasNext) next.prev = prev;
    prev = null;
    next = null;
    if (wasInProgram) workspace.programChanged();
    workspace.moveToTop(this);
    workspace.draw();
    return true;
  }
  
  
  void touchUp(Contact c) {
    if (workspace.snapTogether(this)) {
      Sounds.playSound("click");
      inserted = true;
    } else if (!inserted && workspace.isOverMenu(this)) {
      workspace.snapToEnd(this);
      Sounds.playSound("click");
      inserted = true;
    } else if (workspace.isOffscreen(this) || workspace.isOverMenu(this) || inserted) {
      workspace.removeBlock(this);
      Sounds.playSound("crunch");
    }
    dragging = false;
  }
  
  
  void touchCancel(Contact c) {
    touchUp(c);
  }
  
  
  void touchDrag(Contact c) {
    move(c.touchX - _lastX, c.touchY - _lastY);
    _lastX = c.touchX;
    _lastY = c.touchY;
  }
  
  
  void touchSlide(Contact c) { }
}

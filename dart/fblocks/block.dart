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


const HORIZONTAL = 0;
const VERTICAL = 1;
int BLOCK_ORIENTATION = VERTICAL;
const BLOCK_WIDTH = 85; // 58
const BLOCK_HEIGHT = 40;
const LINE_WIDTH = 6.5;
const BLOCK_SPACE = 0; //11;
const BLOCK_MARGIN = 10;


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
  double x = 0.0, y = 0.0, _width = 0.0, _height = 0.0;
  
  /* Text displayed inside the block */
  String text = 'hop';
  
  /* CSS color of the block */
  String color = '#3399aa';
  
  /** CSS color of the text */
  String textColor = 'white';
  
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
  
  bool wasInMenu = true, wasInProgram = false;
  
  
  Block(this.workspace, this.text) {
    id = Block.BLOCK_ID++;
    _width = BLOCK_WIDTH.toDouble();
    _height = BLOCK_HEIGHT.toDouble();
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
    other._height = _height;
    other.text = text;
    other.color = color;
    other.textColor = textColor;
    if (hasParam) {
      other.param = param.clone(other);
    }
  }
  
  
  bool get hasParam => param != null;
  
  bool get hasNext => next != null;
  
  bool get hasPrev => prev != null;
  
  bool get isInProgram => hasPrev;
  
  num get width => _width;
  
  num get height => _height;
  
  num get centerX => x + width / 2;
  
  num get centerY => y + height / 2;
  
  num get connectorX {
    if (BLOCK_ORIENTATION == HORIZONTAL) {
      return targetX + width + BLOCK_SPACE;
    } else {
      return targetX;
    }
  }
  
  
  num get connectorY {
    if (BLOCK_ORIENTATION == HORIZONTAL) {
      targetY;
    } else {
      return targetY + height + BLOCK_SPACE;
    }
  }
  
  
  num get targetX {
    num tx = hasPrev ? prev.connectorX : x;
    if (BLOCK_ORIENTATION == HORIZONTAL && hasPrev && prev.candidate != null) {
      tx += prev.candidate.width + BLOCK_SPACE;
    }
    return tx;
  }

  
  num get targetY {
    if (BLOCK_ORIENTATION == HORIZONTAL) {
      return hasPrev ? prev.connectorY : y;
    } else {
      num ty = hasNext ? next.targetY - height - BLOCK_SPACE : y;
      if (candidate != null) {
        ty -= candidate.height + BLOCK_SPACE;
      }
      return ty;
    }
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
            other.x <= x + width * 1.1 + BLOCK_SPACE &&
            y <= other.y + other.height + BLOCK_SPACE &&
            other.y <= y + height + BLOCK_SPACE);
  }
  
  
/**
 * When the program is running, this evaluates this block for a specific frog
 */
  void eval(Program program) {
    var pval = (param == null) ? null : param.value;
    program.doCommand(text, pval);
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
  
    
/**
 * Is it syntactically ok to put this block after the before block?
 */
  bool checkSyntax(Block before) {
    return !(before is EndProgramBlock);
  }
  
  
/**
 * Callback for when a parameter value has been changed by the user
 */
  void parameterChanged(Parameter param) {
    workspace.preview(this);
  }
  
  
  bool animate() {
    double dx = targetX - x;
    double dy = targetY - y;
    if (dx.abs() > 1) dx *= 0.3;
    if (dy.abs() > 1) dy *= 0.3;
    
    if (dx.abs() > 0 || dy.abs() > 0) {
      move(dx, dy);
      if (hasNext) next.animate();
      return true;
    } else if (hasNext) {
      return next.animate();
    } else {
      return false;
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
  }
  
  
/**
 * Draw drop shadows
 */
  void drawShadow(CanvasRenderingContext2D ctx) {
    _outline(ctx, x + 2.5, y + 2.5, width, height);
    ctx.fillStyle = "rgba(0, 0, 0, 0.2)";
    ctx.fill();
  }
  
  
/**
 * Draw sockets where other blocks can be snapped into place
 */
  void drawSocket(CanvasRenderingContext2D ctx) {
    if (candidate != null) {
      ctx.save();
      {
        candidate._outline(ctx, connectorX, connectorY, candidate.width, candidate.height);
        ctx.lineWidth = 1;
        ctx.setLineDash([8, 5]);
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.6)';
        ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
        ctx.fill();
        ctx.stroke();
      }
      ctx.restore();
    }
  }
  

/**
 * Draw the block
 */
  void draw(CanvasRenderingContext2D ctx) {
    
    if (workspace.isOverMenu(this) && dragging && wasInMenu) {
      ctx.fillStyle = 'orange';
      ctx.strokeStyle = 'orange';
      drawLineArrow(ctx, centerX, centerY, centerX, centerY - height, 18);
    }
    
    //-------------------------------------------
    // expand width if the parameter value is long
    //-------------------------------------------
    if (param != null) {
      double cw = param.getDisplayWidth(ctx) + param.centerX - 14;
      _width = max(cw, BLOCK_WIDTH);
    }
    
    //-------------------------------------------
    // draw block outline
    //-------------------------------------------
    _outline(ctx, x, y, width, height);
    ctx.save();
    {
      ctx.fillStyle = color;
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.5)';
      ctx.lineWidth = 2;
      ctx.fill();
      ctx.stroke();
    }
    ctx.restore();

    //-------------------------------------------
    // draw text label       
    //-------------------------------------------
    var lines = text.split('\n');
    ctx.fillStyle = textColor;
    ctx.font = '200 11pt sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';
    double tx = x + 12;
    double ty = centerY;
    if (lines.length == 1) {
      ctx.fillText(text, tx, ty);
    } else {
      ctx.fillText(lines[0], tx, ty - 7);
      ctx.fillText(lines[1], tx, ty + 7);
    }
    
    //-------------------------------------------
    // draw parameter
    //-------------------------------------------
    if (param != null && !wasInMenu) {
      param.draw(ctx);
    }
  }
  
  
  void _outline(CanvasRenderingContext2D ctx, num x, num y, num w, num h) {
    
    num r0 = (prev == null || prev is BeginBlock) ? 14 : 2;
    num r1 = (next == null || next is EndBlock) ? 14 : 2;
    num r2 = 2;
    num n = 20;
    
    ctx.beginPath();
    ctx.moveTo(x + r0, y);
    if (!(this is StartBlock)) {
      ctx.lineTo(x + n, y);
      ctx.lineTo(x + n + 5, y + 4);
      ctx.lineTo(x + n + 10, y + 4);
      ctx.lineTo(x + n + 15, y);
    }
    ctx.lineTo(x + w - r2, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r2);
    ctx.lineTo(x + w, y + h - r2);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r2, y + h);
    if (!(this is EndProgramBlock)) {
      ctx.lineTo(x + n + 15, y + h);
      ctx.lineTo(x + n + 10, y + h + 4);
      ctx.lineTo(x + n + 5, y + h + 4);
      ctx.lineTo(x + n, y + h);
    }
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
    wasInProgram = isInProgram;
    _lastX = c.touchX;
    _lastY = c.touchY;
    if (hasPrev) prev.next = next;
    if (hasNext) next.prev = prev;
    prev = null;
    next = null;
    workspace.moveToTop(this);
    workspace.draw();
    return true;
  }
  
  
  void touchUp(Contact c) {
    if (workspace.snapTogether(this)) {
      Sounds.playSound("click");
      workspace.preview(this);
    } else if (wasInMenu && workspace.isOverMenu(this)) {
      if (workspace.snapToEnd(this)) {
        Sounds.playSound("click");
        workspace.preview(this);
      }
    } else if (workspace.isOffscreen(this) || workspace.isOverMenu(this) || wasInProgram) {
      workspace.removeBlock(this);
      Sounds.playSound("crunch");
    }
    dragging = false;
    wasInMenu = false;
    workspace.draw();
  }
  
  
  void touchDrag(Contact c) {
    move(c.touchX - _lastX, c.touchY - _lastY);
    _lastX = c.touchX;
    _lastY = c.touchY;
    workspace.draw();
  }
  
  
  void touchSlide(Contact c) { }
}

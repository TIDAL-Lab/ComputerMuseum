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


const BLOCK_WIDTH = 58;
const BLOCK_HEIGHT = 38;
const LINE_WIDTH = 6.5;
  
  
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
  
  /* Center of the block */
  double x = 0.0, y = 0.0;
  
  /* Used for dragging the block on the screen */
  double deltaX, deltaY, lastX, lastY;
  
  /* Used to animate blocks automatically */
  double _targetX = 0.0, _targetY = 0.0;
  
  /* Text displayed inside the block */
  String text = 'hop';
  
  /* CSS color of the block */
  String color = '#3399aa';
  
  /** CSS color of the text */
  String textColor = 'white';
  
  /* Is the block being dragged */
  bool dragging = false;
  
  /* Highlight the outgoing connector */
  bool highlight = false;
  
  /* Next block in the chain */
  Block next;
  
  /* Previous block in the chain */
  Block prev;
  
  /* Parameter for this block? */
  Parameter param = null;
  
  bool wasInProgram = false;
  
  bool wasInMenu = true;
  
  
  Block(this.workspace, this.text) {
    id = Block.BLOCK_ID++;
  }
  
  
  Block clone() {
    Block b = new Block(workspace, text);
    b.x = x;
    b.y = y;
    b.color = color;
    b.textColor = textColor;
    if (hasParam) {
      b.param = param.clone(b);
    }
    return b;
  }
  
  
  bool get hasParam => param != null;
  
  bool get hasNext => next != null;
  
  bool get hasPrev => prev != null;
  
  int get width => BLOCK_WIDTH;
  
  int get height => BLOCK_HEIGHT;
  
  bool get isInProgram => (isStartBlock || hasPrev);
  
  bool get isStartBlock => false;
  
  num get connectorX => targetX + BLOCK_WIDTH * 1.2;
  
  num get connectorY => targetY;
  
  num get targetY {
    if (_targetY != 0.0) {
      return _targetY;
    } else {
      return hasPrev ? prev.connectorY : y;
    }
  }
    
  num get targetX {
    if (_targetX != 0.0) {
      return _targetX;
    } else if (hasPrev) {
      num tx = prev.connectorX;
      if (prev.highlight) tx += BLOCK_WIDTH * 1.2;
      return tx;
    } else {
      return x;
    }
  }
  

/**
 * When the program is running, this evaluates this block for a specific frog
 */
  void eval(Frog frog, [bool preview = false]) {
    frog.doCommand(text, param, preview);
  }
  
  
/**
 * Advances the program to the next statement
 */
  Block step(Frog frog) {
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
 * Is it syntactically ok to put this block after the 'before' block?
 */
  bool checkSyntax(Block before) {
    return true;
  }
  
  
/**
 * Callback for when a parameter value has been changed by the user
 */
  void parameterChanged(Parameter param) {
    workspace.preview(this);
  }
  
  
  bool animate() {
    if (isInProgram) {
      double dx = targetX - x;
      double dy = targetY - y;
      if (dx.abs() > 1 || dy.abs() > 1) {
        y += dy * 0.3;
        x += dx * 0.3;
        if (hasNext) next.animate();
        return true;
      } else if (hasNext) {
        return next.animate();
      } else {
        return false;
      }
    }
    else if (_targetX != 0.0 || _targetY != 0.0) {
      double dx = targetX - x;
      double dy = targetY - y;
      if (dx.abs() > 1 || dy.abs() > 1) {
        x += dx * 0.3;
        y += dy * 0.3;
        return true;
      } else {
        _targetX = 0.0;
        _targetY = 0.0;
        return false;
      }
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
  

  bool overlapsConnector(Block target) {
    double cx = connectorX;
    double cy = connectorY;
    double tx = target.x;
    double ty = target.y;
    return (distance(cx, cy, tx, ty) < BLOCK_WIDTH);
  }


/**
 * Add target into the chain of blocks after this block
 */
  bool snapTogether(Block target) {
    //if (overlapsConnector(target)) {
      if (hasNext) {
        target.next = next;
        next.prev = target;
      }
      target.prev = this;
      next = target;
      return true;
    //} else {
    //  return false;
    //}
  }
  
  
/**
 * Draw connecting lines
 */
  void drawLines(CanvasRenderingContext2D ctx) {
    if (hasPrev && !(prev is IfBlock)) {
      ctx.save();
      ctx.lineWidth = LINE_WIDTH;
      ctx.lineCap = 'butt';
      ctx.strokeStyle = 'white';
      ctx.beginPath();
      ctx.moveTo(prev.x, targetY);
      ctx.lineTo(x, targetY);
      ctx.stroke();
      ctx.restore();
    }
  }
  
  
/**
 * Draw parameters
 */
  void drawParams(CanvasRenderingContext2D ctx) {
    if (isInProgram && param != null) {
      param.draw(ctx);
    }
  }
  

/**
 * Draw the block
 */
  void draw(CanvasRenderingContext2D ctx) {
    
    if (workspace.isOverMenu(this) && dragging) {
      ctx.fillStyle = 'orange';
      ctx.strokeStyle = 'orange';
      drawLineArrow(ctx, x, y, x, y - height, 18);
    }
    
    _outline(ctx, x, y, width, height);
    ctx.save();
    {
      ctx.shadowOffsetX = 2;
      ctx.shadowOffsetY = 2;
      ctx.shadowColor = "rgba(0, 0, 0, 0.2)";
      ctx.fillStyle = color;
      ctx.fill();
    }
    ctx.restore();
    
    ctx.save();
    {
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.5)';
      ctx.lineWidth = 2;
      ctx.stroke();
    }
    ctx.restore();
      
    ctx.fillStyle = textColor;
    ctx.font = '200 11pt sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    var lines = text.split('\n');
    if (lines.length == 1) {
      ctx.fillText(text, x, y);
    } else {
      ctx.textBaseline = 'bottom';
      ctx.fillText(lines[0], x, y);
      ctx.textBaseline = 'top';
      ctx.fillText(lines[1], x, y);
    }
    
  }
  
  
  void _outline(CanvasRenderingContext2D ctx, num x, num y, num w, num h) {
    ctx.beginPath();
    ctx.arc(x, y, w/2, 0, PI * 2, true);
    //roundRect(ctx, x - w/2, y - h/2, w, h, h/3);
  }

  
/**
 * Draw sockets where other blocks can be snapped into place
 */
  void drawSockets(CanvasRenderingContext2D ctx) {
    if (highlight) {
      double cx = connectorX;
      double cy = connectorY;
      num cw = width;
      num ch = height;
      ctx.save();
      {
        ctx.lineWidth = 2;
        //ctx.setLineDash([8, 5]);
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.6)';
        ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
        _outline(ctx, cx, cy, cw, ch);
        ctx.fill();
        ctx.stroke();
      }
      ctx.restore();
    }
  }
  
  
/*  
  void _clamp(int x, int y, int w, int h, int r) {
    int p = INDENT;
    int x0 = x;
    int x1 = x0 + w;
    int x2 = x + width - p;
    int x3 = x2 + p;
    ctx.beginPath();
    ctx.moveTo(x0 + r, y);
    ctx.lineTo(x1 - r, y);
    ctx.quadraticCurveTo(x1, y, x1, y + r);
    ctx.lineTo(x1, y + h + MARGIN - r);
    ctx.quadraticCurveTo(x1, y + h + MARGIN, x1 + r, y + h + MARGIN);
    ctx.lineTo(x2 - r, y + h + MARGIN);
    ctx.quadraticCurveTo(x2, y + h + MARGIN, x2, y + h + MARGIN - r);
    ctx.lineTo(x2, y + r);
    ctx.quadraticCurveTo(x2, y, x2 + r, y);
    ctx.lineTo(x3 - r, y);
    ctx.quadraticCurveTo(x3, y, x2 + p, y + r);
    ctx.lineTo(x3, y + h + MARGIN + p - r);
    ctx.quadraticCurveTo(x3, y + h + MARGIN + p, x3 - r, y + h + MARGIN + p);
    ctx.lineTo(x0 + r, y + h + MARGIN + p);
    ctx.quadraticCurveTo(x0, y + h + MARGIN + p, x0, y + h + MARGIN + p - r);
    ctx.lineTo(x0, y + r);
    ctx.quadraticCurveTo(x0, y, x + r, y);
    ctx.closePath();
  }
*/  
  
  
  bool containsTouch(Contact c) {
    return distance(c.touchX, c.touchY, x, y) <= width ~/ 2;
  }
  
  
  bool touchDown(Contact c) {
    deltaX = c.touchX - x;
    deltaY = c.touchY - y;
    lastX = x;
    lastY = y;
    dragging = true;
    wasInProgram = isInProgram;
    if (isInProgram) {
      workspace.restartProgram();
    }
    if (prev != null && next == null) {
      prev.next = null;
      prev = null;
    }
    else if (prev == null && next != null) {
      next.prev = null;
      next = null;
    }
    else if (prev != null && next != null) {
      prev.next = next;
      next.prev = prev;
      prev = null;
      next = null;
    }
    workspace.moveToTop(this);
    //workspace.preview(this);
    workspace.repaint();
    return true;
  }
  
  
  void touchUp(Contact c) {
    if (workspace.snapTogether(this)) {
      Sounds.playSound("click");
    } else if (wasInMenu && workspace.isOverMenu(this)) {
      _targetX = x - 5.0;
      _targetY = y - 85.0;
    } else if (wasInProgram || workspace.isOffscreen(this)) {
      workspace.removeBlock(this);
      Sounds.playSound("crunch");
    }
    dragging = false;
    wasInMenu = false;
    workspace.repaint();
  }
  
  
  void touchDrag(Contact c) {
    move((c.touchX - deltaX) - lastX, (c.touchY - deltaY) - lastY);
    lastX = x;
    lastY = y;
    workspace.repaint();
  }
  
  
  void touchSlide(Contact c) {
  }
}

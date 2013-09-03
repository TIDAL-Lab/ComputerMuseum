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
 * Current status for this workstation (frog color, flies eaten, gems found)
 */
class StatusInfo {

  num x, y, w, h;
  
  ImageElement frog = new ImageElement();
  
  ImageElement fly = new ImageElement();
  
  List<Gem> gems = new List<Gem>();
  
  Gem captured = null;
  
  CodeWorkspace workspace;
  
  int fly_count = 0;

  
  StatusInfo(this.workspace, this.x, this.y, this.w, this.h) {
    frog.src = "images/${workspace.color}frog.png";
    fly.src = "images/dragonfly.png";
    for (var color in Gem.colors) {
      Gem gem = new Gem.fromColor(color);
      gem.size = 0.4;
      gem.shadowed = true;
      gems.add(gem);
    }
  }
  
  
  bool animate() {
    if (captured != null) {
      return captured.animate();
    } else {
      return false;
    }
  }

  
  void captureGem(Gem g) {
    captured = new Gem.copy(g);
    captured.x = workspace.worldToObjectX(g.x, g.y);
    captured.y = workspace.worldToObjectY(g.x, g.y);
    for (Gem gem in gems) {
      if (gem.color == captured.color) {
        captured.flyTo(gem.x, gem.y, () {
          gem.shadowed = false;
          workspace.draw();
          captured = null;
        });
      }
    }
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save();
    {
      ctx.fillStyle = '#3e5d64';
      ctx.strokeStyle = '#223333';
      ctx.lineWidth = 3;
      
      ctx.beginPath();
      ctx.moveTo(x, y + h);
      ctx.bezierCurveTo(x - 15, y - h/2, x + 40, y + 25, x + w + 6, y);
      ctx.lineTo(x + w + 6, y + h);
      ctx.fill();
      ctx.stroke();
      
      int iw = (frog.width * 0.75).toInt();
      int ih = (frog.height * 0.75).toInt();
      int ix = x + 10;
      int iy = y + h - ih;
      ctx.drawImageScaled(frog, ix, iy, iw, ih);
      
      ix += iw + 10;
      iy = y + h - h ~/ 3;
      for (Gem gem in gems) {
        ix += gem.width ~/ 2;
        gem.x = ix.toDouble();
        gem.y = iy.toDouble();
        gem.draw(ctx);
        ix += gem.width ~/ 2 + 10;
      }
      
      ix = x + 30 + frog.width;
      iy = y + 30;
      iw = (fly.width * 0.6).toInt();
      ih = (fly.height * 0.6).toInt();
      for (int i=0; i<min(fly_count, 6); i++) {
        ctx.drawImageScaled(fly, ix, iy, iw, ih);
        ix += fly.width;
      }
      
      if (captured != null) {
        captured.draw(ctx);
      }
    }
    ctx.restore();
  }
}

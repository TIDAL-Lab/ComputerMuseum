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
  
  List<Gem> gems = new List<Gem>();
  
  CodeWorkspace workspace;

  
  StatusInfo(this.workspace, this.x, this.y, this.w, this.h) {
    frog.src = "images/bluefrog.png";
    for (var color in Gem.colors) {
      Gem gem = new Gem.fromColor(color);
      gem.size = 0.5;
      gem.shadowed = true;
      gems.add(gem);
    }
  }

  
  void captureGem(Gem captured) {
    Gem target = null;
    for (Gem gem in gems) {
      if (gem.color == captured.color) {
        captured.flyTo(gem.x, gem.y, () {
          gem.shadowed = false;
          workspace.repaintBackground();
        });
      }
    }
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    ctx.save();
    {
      ctx.fillStyle = '#3e5d64';
      ctx.strokeStyle = '#223333';
      ctx.lineWidth = 5;
      
      ctx.beginPath();
      ctx.moveTo(x, y + h);
      ctx.bezierCurveTo(x - 15, y - h/2, x + 40, y + 25, x + w + 6, y);
      ctx.lineTo(x + w + 6, y + h);
      ctx.fill();
      ctx.stroke();
      
      int ix = x + 10;
      int iy = y + 10;
      int iw = frog.width ~/ 2;
      int ih = frog.height ~/ 2;
      ctx.drawImageScaled(frog, ix, iy, iw, ih);
      
      ix += iw + 20;
      iy = y + h - h ~/ 3;
      for (Gem gem in gems) {
        ix += gem.width / 2;
        gem.x = ix.toDouble();
        gem.y = iy.toDouble();
        gem.draw(ctx);
        ix += gem.width / 2 + 10;
      }
    }
    ctx.restore();
  }
}

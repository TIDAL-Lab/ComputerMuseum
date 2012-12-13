/*
 * Computer History Museum
 */
part of ComputerHistory;

class Turtle implements Touchable {
  
   static Random rnd = new Random();
   
   int id;            // all turtles have a unique id number
   num x = 0, y = 0;  // turtle coordinates in world space
   num size = 1;      // turtle size
   num heading = 0;   // turtle heading in radians
   Color color;       // turtle color
   Model model;       // reference back to the containing model
   bool dead = false; // flag used to remove turtle from the model

   var drawShape = null;   // function to draw specific turtle shapes
   
   
   Turtle(this.model) {
      id = model.nextTurtleId();
      heading = rnd.nextDouble() * PI * 2;
      color = new Color(255, 255, 0, 50);
   }
   
   
   Turtle clone(Turtle parent) {
      Turtle t = new Turtle(model);
      t.x = x;
      t.y = y;
      t.size = size;
      t.heading = heading;
      t.color = color.clone();
      t.dead = false;
      return t;
   }
   
   
   void setXY(num x, num y) {
      this.x = wrapX(x);
      this.y = wrapY(y);
   }
   
   
   void forward(num distance) {
      x = wrapX(x - sin(heading) * distance);
      y = wrapY(y + cos(heading) * distance);
   }
   
      
   void backward(num distance) {
      forward(-distance);
   }
   
   
   void left(num degrees) {
      heading -= (degrees / 180) * PI;
      if (heading > 2 * PI) {
        heading = heading % (2 * PI);
      } else if (heading < 0) {
        heading = (2 * PI) + heading % (2 * PI);
      }
   }
   
   
   void right(num degrees) {
      left(-degrees);
   }
   
   
   void die() {
      dead = true;
   }
   
   
   Turtle hatch() {
      Turtle copy = clone(this);
      model.addTurtle(copy);
      return copy;
   }
   
   
   num wrapX(num tx) {
     /*
      while (tx < model.minWorldX) {
         tx += model.worldWidth;
      }
      while (tx > model.maxWorldX) {
         tx -= model.worldWidth;
      }
      */
      return tx;
   }
   
   
   num wrapY(num ty) {
     /*
      while (ty < model.minWorldY) {
         ty += model.worldHeight;
      } 
      while (ty > model.maxWorldY) {
         ty -= model.worldHeight;
      } 
      */
      return ty;
   }
   
   
   void draw(var ctx) {
      if (drawShape != null) {
         drawShape(ctx);
      } else {
         roundRect(ctx, -0.2, -0.5, 0.4, 1, 0.2);
         ctx.fillStyle = color.toString();
         ctx.fill();
         ctx.strokeStyle = "rgba(255, 255, 255, 0.5)";
         ctx.lineWidth = 0.05;
         ctx.stroke();
      }
   }
   
   
   void tick() {
      if (dead) return;
   }
   
   
   void roundRect(var ctx, num x, num y, num w, num h, num r) {
      ctx.beginPath();
      ctx.moveTo(x+r,y);
      ctx.arcTo(x+w,y,x+w,y+r,r);
      ctx.arcTo(x+w,y+h,x+w-r,y+h,r);
      ctx.arcTo(x,y+h,x,y+h-r,r);
      ctx.arcTo(x,y,x+r,y,r);
   }
   
   
   //-------------------------------------------------------------------
   // Touchable implementation
   //-------------------------------------------------------------------
   bool containsTouch(Contact event) {
      double tx = model.screenToWorldX(event.touchX, event.touchY);
      double ty = model.screenToWorldY(event.touchX, event.touchY);
      return (tx >= x-size/2 && tx <= x+size/2 && ty >= y-size/2 && ty <= y+size/2);
   }
   
   
   bool touchDown(Contact event) {
      color.setColor(255, 0, 0, 255);
      return true;
   }
   
   
   void touchUp(Contact event) {
      color.setColor(0, 255, 0, 255);
   }
   
   
   void touchDrag(Contact event) {      
      double tx = model.screenToWorldX(event.touchX, event.touchY);
      double ty = model.screenToWorldY(event.touchX, event.touchY);
      x = tx;
      y = ty;
   }
   
   
   void touchSlide(Contact event) { }
}
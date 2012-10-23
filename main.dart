#library('jigsaw');

#import('dart:html');
#import('dart:math');
#import('dart:json');


#source('JsonObject.dart');
#source('Touch.dart');
#source('Tween.dart');
#source('Block.dart');

void main() {
   new App();
}


class App extends TouchManager {
   
   CanvasRenderingContext2D background;
   CanvasRenderingContext2D foreground;
   
   int width = 1000;
   int height = 700;
   
   Block block;

   
   App() {
      width = window.innerWidth;
      height = window.innerHeight;
  
      CanvasElement canvas = document.query("#background");
      canvas.width = width;
      canvas.height = height;
      background = canvas.getContext("2d");
      
      canvas = document.query("#foreground");
      canvas.width = width;
      canvas.height = height;
      foreground = canvas.getContext("2d");
      registerEvents(canvas);
      window.setTimeout(animate, 20);

      block = new Block(10, 10);
      addTouchable(block);
   }
   
   void animate() {
      block.animate();
      draw();
      window.setTimeout(animate, 20);
   }


   void draw() {
      var ctx = foreground;
      ctx.clearRect(0, 0, width, height);
      ctx.fillStyle = 'red';
      ctx.fillRect(234, 345, 100, 200);
      block.draw(ctx);
   }

   
   void drawBackground() {
      var ctx = background;
      ctx.clearRect(0, 0, width, height);
   }
}

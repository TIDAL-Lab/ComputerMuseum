
class Block implements Touchable {
  
  int x, y;
  
  Block(this.x, this.y);
  
   bool containsTouch(TouchEvent event) {
     if (event.tagId == 0x19) {
       return true;
     }  
   }
    
    void touchDown(TouchEvent event) {
      x = event.touchX;
      y = event.touchY;

    }
    
    void touchUp(TouchEvent event) {
      x = 0;
      y = 0;
    }
    
    void touchDrag(TouchEvent event) {
      x = event.touchX;
      y = event.touchY;
      print("$x, $y");
    }
    
    void animate() {
    }
    
    void draw(var ctx) {
      ctx.fillStyle = "rgba(255, 255, 255, 0.8)";
      ctx.textAlign = "center";
      ctx.textBaseline = "top";
      ctx.fillText("BEGIN", x, y + 80);
    }
  
}

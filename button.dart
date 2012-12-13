/*
 * Computer History Museum Exhibit
 */
part of ComputerHistory;


class Button implements Touchable {

   // (optional) this is returned with callback functions
   var action = null;
   
   // button image icon
   var img;
   
   // button location and size
   int x, y, width = 0, height = 0;
   
   // callback when the button is released
   var onClick = null;
   
   // callback when the button is first pressed
   var onDown = null;
   
   // button can be clicked on
   bool enabled = true;
   
   // is the button down 
   bool down = false;
   
   // is the button visible
   bool visible = true;
      

   Button(this.x, this.y, this.action);

   
   void setImage(var path) {
      img = new ImageElement();
      img.src = path;
      img.on.load.add((e) { width = img.width; height = img.height; } );
   }
   

//-------------------------------------------------------------
// Touchable implementation
//-------------------------------------------------------------
   bool containsTouch(Contact event) {
      num tx = event.touchX;
      num ty = event.touchY;
      return (tx >= x && ty >= y && tx <= x + width && ty <= y + height);
   }
   
   
   bool touchDown(Contact event) {
      down = true;
      if (onDown != null) onDown(action);
      return true;
   }
   
   
   void touchUp(Contact event) {
      down = false;
      if (onClick != null && containsTouch(event)) {
         onClick(action);
      }
   }
   
   
   void touchDrag(Contact event) { 
      down = containsTouch(event);
   }
   
   
   void touchSlide(Contact event) { }

   
   void draw(var ctx) {
      if (!visible) return;
      int ix = down? x + 3 : x;
      int iy = down? y + 3 : y;
      int iw = width;
      int ih = height;
      
      ctx.drawImage(img, ix, iy, iw, ih);
   }
}

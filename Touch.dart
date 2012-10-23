/*
 * NetTango
 *
 * Michael S. Horn
 * Northwestern University
 * michael-horn@northwestern.edu
 * Copyright 2012, Michael S. Horn
 *
 * This project was funded in part by the National Science Foundation.
 * Any opinions, findings and conclusions or recommendations expressed in this
 * material are those of the author(s) and do not necessarily reflect the views
 * of the National Science Foundation (NSF).
 */
class TouchManager {

   // A list of touchable objects on the screen
   var touchables;
   
   // Bindings from event IDs to touchable objects
   var touch_bindings;
   
   // Touch event frame from microsoft surface
   var pframe = null;
   
   // Is the mouse currently down
   bool mdown = false;
   
   
   TouchManager() {
      touchables = new List<Touchable>();
      touch_bindings = new Map<int, Touchable>();
   }
   

/*
 * The main class must call this method to enable mouse and touch input
 */ 
   void registerEvents(var canvas) {
      canvas.on.mouseDown.add((e) => mouseDown(e), true);
      canvas.on.mouseUp.add((e) => mouseUp(e), true);
      canvas.on.mouseMove.add((e) => mouseMove(e), true);
      
      // Attempt to connect to the microsoft surface input stream
      try {
         var socket = new WebSocket("ws://localhost:405");
         socket.on.open.add((evt) => print("connected to surface."));
         socket.on.message.add((evt) => processTouches(evt.data));
         socket.on.error.add((evt) => print("error in surface connection."));
         socket.on.close.add((evt) => print("surface connection closed."));
      }
      catch (x) {
         print("unable to connect to surface.");
      }
   }
   
   
/*
 * Add a touchable object to the list
 */
   void addTouchable(Touchable t) {
      touchables.add(t);
   }
   

/*
 * Remove a touchable object from the master list
 */
   void removeTouchable(Touchable t) {
      for (int i=0; i<touchables.length; i++) {
         if (t == touchables[i]) {
            touchables.removeRange(i, 1);
            return;
         }
      }
   }
   
   
/*
 * Find a touchable object that intersects with the given touch event
 */
   Touchable findTouchTarget(TouchEvent tp) {
      for (var t in touchables) {
         if (t.containsTouch(tp)) {
            print("found one");
            return t;
         }
      }
      return null;
   }
   

/*
 * Convert mouseUp to touchUp events
 */
   void mouseUp(MouseEvent evt) {
      var target = touch_bindings[-1];
      if (target != null) {
         target.touchUp(new TouchEvent.fromMouse(evt));
         touch_bindings[-1] = null;
      }
      mdown = false;
   }
   
   
/*
 * Convert mouseDown to touchUp events
 */
   void mouseDown(MouseEvent evt) {
      TouchEvent t = new TouchEvent.fromMouse(evt);
      var target = findTouchTarget(t);
      if (target != null) {
         touch_bindings[-1] = target;
         target.touchDown(t);
      }
      mdown = true;
   }
   
   
/*
 * Convert mouseMove to touchDrag events
 */
   void mouseMove(MouseEvent evt) {
      if (mdown) {
         var target = touch_bindings[-1];
         if (target != null) {
            target.touchDrag(new TouchEvent.fromMouse(evt));
         }
      }
   }
   
   
   void touchDown(var tframe) {
      for (var t in tframe.changedTouches) {
         if (t.down) {
            var target = findTouchTarget(t);
            if (target != null) {
               touch_bindings[t.id] = target;
               target.touchDown(t);
            }
         }
      }
   }
   
   
   void touchUp(var tframe) {
      for (var t in tframe.changedTouches) {
         if (t.up) {
            var target = touch_bindings[t.id];
            if (target != null) {
               target.touchUp(t);
               touch_bindings[t.id] = null;
            }
         }
      }
      if (tframe.touches.length == 0) {
         touch_bindings = [];
      }
   }
   
   
   void touchDrag(var tframe) {
      for (var t in tframe.changedTouches) {
         if (t.drag) {
            var target = touch_bindings[t.id];
            if (target != null) {
               target.touchDrag(t);
            }
         }
      }
   }
   

/*
 * Process JSON touch events from microsoft surface
 */
   void processTouches(data) {
      var frame = new JsonObject.fromJsonString(data);
      
      var changed = [];
      bool down = false;
      bool drag = false;
      bool up = false;
      
      for (var t in frame.touches) {
         if (t.down) {
            changed.add(new TouchEvent.fromJSON(t));
            down = true;
         }
         else if (t.drag) {
            changed.add(new TouchEvent.fromJSON(t));
            drag = true;
         }
         else if (t.up) {
            changed.add(new TouchEvent.fromJSON(t));
            up = true;
         }
      }
      
      frame.changedTouches = changed;
      if (down) touchDown(frame);
      if (drag) touchDrag(frame);
      if (up) touchUp(frame);
      
      pframe = frame;
   }
}


interface Touchable {
   
   bool containsTouch(TouchEvent event);
   
   void touchDown(TouchEvent event);
   
   void touchUp(TouchEvent event);
   
   void touchDrag(TouchEvent event);

}


class TouchEvent {
   int id;
   int tagId = -1;
   num touchX = 0;
   num touchY = 0;
   bool tag = false;
   bool up = false;
   bool down = false;
   bool drag = false;
   bool finger = false;
   
   TouchEvent(this.id);
   
   TouchEvent.fromMouse(MouseEvent mouse) {
      id = -1;
      touchX = mouse.clientX;
      touchY = mouse.clientY;
      finger = true;
   }
   
   TouchEvent.fromJSON(var json) {
      id = json.identifier;
      touchX = json.pageX;
      touchY = json.pageY;
      up = json.up;
      down = json.down;
      drag = json.drag;
      tag = json.tag;
      tagId = json.tagId;
   }
}

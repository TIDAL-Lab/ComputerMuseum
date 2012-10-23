
const TWEEN_LINEAR = 0;
const TWEEN_SINE2  = 1;
const TWEEN_DECAY  = 2;

final int REPEAT_FOREVER = -1;


class Tween {
   var segments;                 // array of interpolation points
   int delay     = 0;            // delay time in ticks
   int duration  = 0;            // duration of tween in ticks
   int count     = 0;            // current tick count
   int function  = TWEEN_LINEAR; // interpolation function
   bool running  = true;         // paused or not
   int repeat    = 1;            // repeat count
   
   var ontick    = null;         // action callback
   var ondelta   = null;         // action callback
   var onend     = null;         // tween complete callback
   var onstart   = null;         // tween beginning callback
   
   Tween() {
      segments = [];
   }
   
   void play() {
      count = 0;
      running = true;
      animate();
   }
   
   
   void stop() {
      running = false;
      count = 1;
      repeat = 0;
   }

   
   bool isRunning() => running;
   
   bool isDelaying() => (count < delay);

   
   bool isTweening() {
      if (repeat == REPEAT_FOREVER) {
         return true;
      } else {
         return count <= (duration * repeat) + delay;
      }
   }
   
   
   void clearControlPoints() {
      segments = [];
   }
   
   
   void addControlPoint(num value, num time) {
      segments.add(new ControlPoint(value, time));
      segments.sort((a, b) => (a.time - b.time));
   }
   
   
   num getValue() {
      num t = getTime();
      num len = segments.length;
      if (len == 0) return 0;
      if (len == 1) segments[0];
      var prev = segments[0];
      var next = segments[len-1];
      
      for (var curr in segments) {
         if (curr.time <= t) {
            prev = curr;
         } else {
            next = curr;
            break;
         }
      }
      
      if (prev.time >= next.time) {
         return next.value;
      }
      
      t = (t - prev.time) / (next.time - prev.time);
      t = min(1, max(t, 0));
      
      num y = getY(t);
      num a = prev.value;
      num b = next.value;
      return (y * (b - a) + a);
   }
   
   
   num getTime() {
      num t = (count - delay) / duration;
      if (t < 0) {
         return 0;
      } else if (t > 1 && repeat != 1) {
         return t - t.floor();
      } else {
         return t;
      }
   }

   
   num getY(num time) {
      num x;
      switch (function) {
         case TWEEN_LINEAR:
            return time;
         case TWEEN_SINE2:
            x = time * PI * 0.5;
            return sin(x) * sin(x);
         case TWEEN_DECAY:
            return 1 - exp(time * -5);
         default:
            return time;
      }
   }
   
   
   void animate() {
      if (!running) return;
      
      if (isTweening()) {
         if (delay == 0 && count == 0) {
            if (onstart != null) onstart();
         }
         num a = getValue();
         count++;
         num b = getValue();
         
         if (delay == count) {
            if (onstart != null) onstart();
         }
         
         if (isTweening() && !isDelaying()) {
            if (ontick != null) {
               ontick(b);
            }
            if (ondelta != null) {
               ondelta(b - a);
            }
         }
         
         if (!isTweening()) {
            if (onend != null) onend();
         }
      }
   }
}


class ControlPoint {
   num value = 0;
   num time = 0;
   ControlPoint(this.value, this.time);
}


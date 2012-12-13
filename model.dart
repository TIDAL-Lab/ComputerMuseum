/*
 * Computer History Museum Exhibit
 */
part of ComputerHistory;


abstract class Model extends TouchLayer {
   
  // Drawing context for turtles
  CanvasRenderingContext2D tctx;
  
  // A collection of turtles in the model
  List turtles;
   
  // List of dead turtles
  List deadTurtles;
   
  // Size of a patch in pixels
  // TODO: Maybe patch size should vary according to world size rather than vice versa
  int patchSize = 40;
   
  // Dimensions of the world in patch coordinates
  int maxPatchX = 12;
  int minPatchX = -12;
  int maxPatchY = 12;
  int minPatchY = -12;
   
  // Used to generate unique turtle id numbers
  int TURTLE_ID = 0;
   
  static Random rnd = new Random();
   
   
  Model() : super("turtles") {
    super.resizeToFitScreen();
    TouchManager.addLayer(this);
    turtles = new List<Turtle>();
    deadTurtles = new List<Turtle>();
    tctx = super.context;
  }
   
   
  void setup();
   
   
  void addTurtle(Turtle t) {
    turtles.add(t);
    addTouchable(t);
  }
   
   
  void clearTurtles() {
    for (var t in turtles) {
      removeTouchable(t);
    }
    turtles = new List<Turtle>();
    deadTurtles = new List<Turtle>();
  }
   
   
  Turtle oneOfTurtles() {
    return turtles[rnd.nextInt(turtles.length)];
  }
   
   
  void resize(int x, int y, int w, int h) {
    super.resize(x, y, w, h);
    int hpatches = w ~/ patchSize;
    int vpatches = h ~/ patchSize;
    maxPatchX = hpatches ~/ 2;
    maxPatchY = vpatches ~/ 2;
    minPatchX = maxPatchX - hpatches + 1;
    minPatchY = maxPatchY - vpatches + 1;
  }
   
   
  void tick(int count) {
     
    // remove dead turtles
    for (int i=turtles.length - 1; i >= 0; i--) {
      Turtle t = turtles[i];
      if (t.dead) {
        turtles.removeAt(i);
        removeTouchable(t);
        deadTurtles.add(t);
      }
    }
      
    // animate turtles
    for (var turtle in turtles) {
      turtle.tick();
    }
  }
   
   
  void draw() {
    drawTurtles(tctx);
  }
 
   
  void drawTurtles(var ctx) {
    ctx.clearRect(0, 0, width, height);
    num cx = (0.5 - minPatchX) * patchSize;
    num cy = (0.5 - minPatchY) * patchSize;
    ctx.save();
    ctx.translate(cx, cy);
    ctx.scale(patchSize, -patchSize);
    
    for (var turtle in turtles) {
      ctx.save();
      ctx.translate(turtle.x, turtle.y);
      ctx.rotate(turtle.heading);
      turtle.draw(ctx);
      ctx.restore();
    }
    ctx.restore();
  }
   
   
  num screenToWorldX(num sx, num sy) {
    num cx = (0.5 - minPatchX) * patchSize;
    return (sx - cx) / patchSize;
  }
   
   
  num screenToWorldY(num sx, num sy) {
    num cy = (0.5 - minPatchY) * patchSize;
    return (cy - sy) / patchSize;      
  }
   
   
  num worldToScreenX(num wx, num wy) {
    num cx = patchSize * worldWidth * 0.5;
    return (wx * patchSize) + cx;
  }
   
   
  num worldToScreenY(num wx, num wy) {
    num cy = patchSize * worldHeight * 0.5;
    return (-wy * patchSize) + cy;
  }
   
   
  int nextTurtleId() => TURTLE_ID++;
   
  num get minWorldY => minPatchY - 0.5;
  num get minWorldX => minPatchX - 0.5;
  num get maxWorldY => maxPatchY + 0.5;
  num get maxWorldX => maxPatchX + 0.5;
  int get worldWidth => maxPatchX - minPatchX + 1;
  int get worldHeight => maxPatchY - minPatchY + 1;
   
}
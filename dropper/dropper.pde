ArrayList<Ball> balls = new ArrayList<Ball>();

ArrayList<Surface> surfaces = new ArrayList<Surface>(); //declare variables
ArrayList<Liquid> liquids = new ArrayList<Liquid>();
ArrayList<ScoreArea> scoreArea = new ArrayList<ScoreArea>();

Surface movingSurface;

int movingSurfaceVel = 3;
int score = 0;
boolean windRight;
boolean fancy = false;


void setup() {
  size(1000, 800);
  surfaces.add(new Surface(new PVector(25, height/2), 50, height, 0.5)); //right wall
  surfaces.add(new Surface(new PVector(width - 25, height/2), 50, height, 0.5)); //left wall
  surfaces.add(new Surface(new PVector(width/2, height), width, 100, 0.35)); //bottom wall
  
  surfaces.add(new Surface(new PVector(width - 210, height/2), 20, 500, 0.5)); //right inner wall
  surfaces.add(new Surface(new PVector(210, height/2), 20, 500, 0.5)); //left inner wall
  
  surfaces.add(new Surface(new PVector(width/2 - 50, 115), 10, 70, 0.5)); //left center wall
  surfaces.add(new Surface(new PVector(width/2 + 50, 115), 10, 70, 0.5)); //right center wall



  
  liquids.add(new Liquid( new PVector(width/4, 100), width/2 - 100, 100, 3)); //left liquid 
  liquids.add(new Liquid( new PVector(3 * width/4, 100), width/2 - 100, 100, 3)); //right liquid 
  movingSurface = new Surface(new PVector(500, 700), 25, 100, 0.5); //moving surface
  surfaces.add(movingSurface);

  //create pyramid
  int wSep = 30; 
  int hSep = 50;
  int size = 8;
  for(int w = 0; w < size; w++){ //loop through size, going horizontally
    int startingHeight = 200 + hSep * w; 
    for(int h = 0; h < size - w; h++){ //loop through size - w, going vertically
      if(h % 2 == 1) continue; //skip one 
      surfaces.add(new Surface(new PVector(width/2 + (wSep * w), startingHeight + hSep * h), 10, 10, 0.5)); //add surface to the right of starting dot
      surfaces.add(new Surface(new PVector(width/2 - (wSep * w), startingHeight + hSep * h), 10, 10, 0.5)); //add surface to the left of starting dot
    }
    //scoring system
    if(w % 2 == 0){
      int value = int(map(w, 0, size - 2, 1, (size - 2) * 2)); //value of area
      scoreArea.add(new ScoreArea(new PVector(width/2 + (wSep * w), startingHeight + hSep * (size - w)), 50, 50, value));
      
      if(w == 0) continue; //Don't double up on first one
      scoreArea.add(new ScoreArea(new PVector(width/2 - (wSep * w), startingHeight + hSep * (size - w)), 50, 50, value));
      
      continue;
    }
    surfaces.add(new Surface(new PVector(width/2 + (wSep * w), startingHeight + hSep * (size - w)), 10, 50, 0.5)); //add dots
    surfaces.add(new Surface(new PVector(width/2 - (wSep * w), startingHeight + hSep * (size - w)), 10, 50, 0.5));
  }
  balls.add(new Ball());
}




void draw() {
  if(fancy){
    rectMode(LEFT); //gradual background
    fill(255, 255, 255, 25);
    rect(0, 0, width, height);
  } else {
    background(255); //set background
  }
  
  
  rectMode(CENTER);
  fill(44, 206, 50, 150); //create boosting up areas
  rect(100, height-50, 200, height + 400);
  rect(width-100, height-50, 200, height + 400);
  movingSurface.center.x += movingSurfaceVel;
  if(movingSurface.center.x >= width - 150){ //change direction of moving platform
    movingSurfaceVel = -movingSurfaceVel;
  } else if (movingSurface.center.x <= 150){
    movingSurfaceVel = -movingSurfaceVel;
  }
  
  
  if(frameCount % 1000 == 0) windRight = !windRight; //arrow direction
  float windStrength;
  if(windRight){ //find wind strength
    windStrength = map(frameCount % 1000, 0, 1000, -0.1, 0.1);

  } else {
    windStrength = map(frameCount % 1000, 0, 1000, 0.1, -0.1);
  }
  

  for(Ball b : balls) { //loop through balls
    PVector wind = new PVector(windStrength, 0);
    if(b.location.x < 150 && b.location.y > 50 || b.location.x > width - 150 && b.location.y > 50){ //check if in boossting area
      wind.x = 0;
      wind.y = -4;
      b.pointsCounted = false;
    }
    if(b.location.y < 100 && b.location.x > 550){ //check if in water
      wind.x = -0.25; 
    } else if(b.location.y < 100 && b.location.x < 450){
      wind.x = 0.25; 
    }
    PVector gravity = new PVector(0, b.mass * 0.1); //set gravity

    for(Liquid l : liquids){ //loop through liquids
      if (l.contains(b)) {   //check if liquids contain ball
        PVector drag = b.velocity.copy().rotate(radians(180)).div(1.0).mult(l.viscosity);
        PVector buoyancy = new PVector(0, -1).setMag(b.diameter*b.diameter*0.02);
        b.applyForce(drag); //apply forces
        b.applyForce(buoyancy);
      }
    }
    

    b.applyForce(gravity); //apply forces
    b.applyForce(wind);
    
    for(ScoreArea sa : scoreArea){
      if(b.pointsCounted) continue; //check if points have already been counted
      sa.checkCollision(b); 
    }
    
    for(Surface s : surfaces){
      s.checkCollision(b); //check for collision vetween surface and ball
    }
  }

  //display elements
  for(Surface s : surfaces){
    s.display();
  }
  
  for(Liquid l : liquids){
    l.display();
  }
  
  for(ScoreArea sa : scoreArea){
    sa.display(); 
  }
  
  for(Ball b : balls) {
    b.update(); 
  }
  
  
  fill(0); //display score
  textSize(35);
  textAlign(CENTER);
  text("Score: " + score, width/2, 35);
  
  strokeWeight(10); //display wind
  stroke(1);
  pushMatrix();
  translate(width/2 + 150, 200);
  float len = 0;
  len = map(windStrength, -0.1, 0.1, -100, 100); //find length
  
  line(0,0,len, 0);
  if(windStrength <= 0){ //check which way arrow is pointing
    line(len, 0, len + 8, -8);
    line(len, 0, len + 8, 8);
  } else {
    line(len, 0, len - 8, -8);
    line(len, 0, len - 8, 8);
  }
  text("Wind", 0, -20);
  
  popMatrix();
  strokeWeight(1);
  
  textSize(25); //text
  text("Press mouse for \n more balls \n Press f for fancy", 340, 180);
}

void mousePressed(){ //add new balls on mouse press
  balls.add(new Ball()); 
}

void keyPressed(){
  if(key == 'f' || key == 'F'){ //change fancy if pressed f
    fancy = !fancy;
  }
}

class Liquid {
  PVector center; 
  float w, h, viscosity, maxWaveHeight;
  color c;

  Liquid(PVector _center, float _w, float _h, float _viscosity) {
    center = _center.copy();
    w = _w;
    h = _h;
    viscosity = _viscosity;
    c = color(100, 100, 255, 100);
    maxWaveHeight = 20;
  }

  float waveHeight(float x) {
    float time = frameCount/100.0;
    float y1 = maxWaveHeight*noise(10.0 + x/100.0 + time);
    float y2 = maxWaveHeight*noise(20.0 + x/100.0 - time);
    float y3 = maxWaveHeight*noise(30.0 + x/200.0 + time);
    float y4 = maxWaveHeight*noise(40.0 + x/200.0 - time);
    return (y1+y2+y3+y4)/4.0;
  }

  boolean contains(Ball b) {
    return (b.location.x < center.x + w/2 && b.location.x > center.x - w/2 &&
      b.location.y < center.y + h/2 && b.location.y > center.y - h/2);
  }

  void display() {
    fill(c);
    noStroke();
    rectMode(CENTER);
    rect(center.x, center.y, w, h);
    stroke(c);
    for(float x = center.x - w/2; x < center.x + w/2; x++) {
      float wh = waveHeight(x);
      line(x, center.y-h/2-1, x, center.y-h/2-wh);
    }
  }
}

class ScoreArea{
  PVector center; //declare vars
  int w, h;
  int value;
  color c;
  
  
  ScoreArea(PVector center, int w, int h, int value){ //constructor
    this.center = center;
    this.w = w;
    this.h = h;
    this.value = value;
    c = color(255, 0, 0, 100);
  }
  
  void display(){ //display
    fill(c);
    stroke(0);
    rectMode(CENTER);
    rect(center.x, center.y, w, h, 5);
    
    fill(0);
    textSize(20);
    textAlign(CENTER);
    text(value, center.x, center.y + 5);
  }
  
  void checkCollision(Ball b){ //check for collision with ball
    float r = b.diameter/2.0;
    if(b.location.x + r < center.x + w/2 && 
      b.location.x - r > center.x - w/2 &&
      b.location.y + r < center.y + h/2 &&
      b.location.y - r > center.y - h/2){
      
      b.pointsCounted = true;
      score += value;
    }
  }
  
}





class Surface {
  PVector center;
  float w, h;
  float bounciness; // 0 to 1, 0 = no bounce, 1 = very bouncy
  color c;

  Surface(PVector cen, float _w, float _h, float b) {
    center = cen.copy();
    w = _w;
    h = _h;
    bounciness = b;
    c = color(150);
  }

  void checkCollision(Ball b) {
    checkCollisionTop(b); 
    checkCollisionBottom(b);
    checkCollisionLeft(b);
    checkCollisionRight(b);
  }

  void checkCollisionLeft(Ball b) {

    PVector ballnow = b.location.copy();
    PVector v = b.velocity.copy();
    PVector a = b.acceleration.copy();

    v.add(a);
    PVector ballnext = PVector.add(ballnow, v);

    float xleft = center.x - w/2.0;
    float ytop = center.y - h/2.0;
    float ybot = center.y + h/2.0;
    float r = b.diameter/2.0;

    if (ballnow.x < xleft &&
      ballnext.x + r > xleft &&
      ballnow.y > ytop &&
      ballnow.y < ybot) {   // detection

      float vx = b.velocity.x;

      b.velocity.x = 0;               // stop the ball from moving down
      b.acceleration.x = 0;           // stop the  ball from accelerating down
      b.location.x = xleft - r;   

      PVector kick = new PVector(-b.mass * vx * bounciness, vx*random(-1, 1));
      b.applyForce(kick);
    }
  }

  void checkCollisionRight(Ball b) {

    PVector ballnow = b.location.copy();
    PVector v = b.velocity.copy();
    PVector a = b.acceleration.copy();

    v.add(a);
    PVector ballnext = PVector.add(ballnow, v);

    float xright = center.x + w/2.0;
    float ytop = center.y - h/2.0;
    float ybot = center.y + h/2.0;
    float r = b.diameter/2.0;

    if (ballnow.x > xright &&
      ballnext.x - r < xright &&
      ballnow.y > ytop &&
      ballnow.y < ybot) {   // detection

      float vx = b.velocity.x;

      b.velocity.x = 0;               // stop the ball from moving down
      b.acceleration.x = 0;           // stop the  ball from accelerating down
      b.location.x = xright + r;   

      PVector kick = new PVector(-b.mass * vx * bounciness, vx*random(-1, 1));
      b.applyForce(kick);
    }
  }


  void checkCollisionBottom(Ball b) {

    PVector ballnow = b.location.copy();
    PVector v = b.velocity.copy();
    PVector a = b.acceleration.copy();

    v.add(a);
    PVector ballnext = PVector.add(ballnow, v);

    float ybot = center.y + h/2.0;
    float xleft = center.x - w/2.0;
    float xright = center.x + w/2.0;
    float r = b.diameter/2.0;

    if (ballnow.y > ybot &&
      ballnext.y - r < ybot &&
      ballnow.x > xleft &&
      ballnow.x < xright) {   // detection

      float vy = b.velocity.y;

      b.velocity.y = 0;               // stop the ball from moving down
      b.acceleration.y = 0;           // stop the  ball from accelerating down
      b.location.y = ybot + r;   // reposition the ball so it's on the top of the surface

      PVector kick = new PVector(vy*random(-1, 1), -b.mass * vy * bounciness);
      b.applyForce(kick);
    }
  }


  void checkCollisionTop(Ball b) {

    PVector ballnow = b.location.copy();
    PVector v = b.velocity.copy();
    PVector a = b.acceleration.copy();

    v.add(a);
    PVector ballnext = PVector.add(ballnow, v);

    float ytop = center.y - h/2.0;
    float xleft = center.x - w/2.0;
    float xright = center.x + w/2.0;
    float r = b.diameter/2.0;

    if (ballnow.y < ytop &&
      ballnext.y + r > ytop &&
      ballnow.x + r*0.5 > xleft &&
      ballnow.x - r*0.5 < xright) {   // detection

      float vy = b.velocity.y;

      b.velocity.y = 0;               // stop the ball from moving down
      b.acceleration.y = 0;           // stop the  ball from accelerating down
      b.location.y = ytop - r;   // reposition the ball so it's on the top of the surface

      PVector kick = new PVector(vy*random(-1, 1), -b.mass * vy * bounciness);
      b.applyForce(kick);
    }
  }

  void display() {
    fill(c);
    stroke(0);
    rectMode(CENTER);
    rect(center.x, center.y, w, h, 5);
  }
}





class Ball {
  float mass, diameter;
  PVector location, velocity, acceleration; 
  color c;
  boolean pointsCounted;

  Ball() {
    location = new PVector(random(200, width - 200), 0);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    diameter = random(20, 30);
    mass = diameter;
    c = color(random(255), random(255), random(255));
    pointsCounted = false;
  }

  void applyForce(PVector force) {
    acceleration.add(force.div(mass));   // F = ma
  }

  void move() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.setMag(0).limit(10);
  }

  void display() {
    fill(c);
    if(fancy){ //gradual background
      noStroke();
    } else { //set background
      stroke(1);
    }
    circle(location.x, location.y, diameter);
  }

  void update() {
    move();
    display();
  }
}

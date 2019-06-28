void run3(){
   // update the cam
  context.update();

  background(0,0,0);
  
  // set the scene pos
  translate(width/2, height/2, 0);
  rotateX(rotX);

/*
  // auto pan the camera between +90 and -90 degrees, flipping direction when it gets to each end.
  rotY += c*0.02f;
  if (rotY > radians(90) || rotY < -radians(90)){
    c = -1*c;
  }
  */

  rotateY(rotY);
  scale(zoomF);
  
  //PImage rgbImage = context.rgbImage();  
  int[]   depthMap = context.depthMap();
  int[]   userMap = context.userMap();
  int     steps = 40;  // to speed up the drawing, draw every fourth point
  int     index;
  PVector realWorldPoint;
  pts.clear();//reset points
 
  translate(-1000,-500,-1500);  // set the rotation center of the scene 1000 infront of the camera

  // draw the pointcloud
  beginShape(POINTS);
  for(int y=0;y < context.depthHeight();y+=steps){
    for(int x=0;x < context.depthWidth();x+=steps){
      index = x + y * context.depthWidth();
      if(depthMap[index] > 0){ 
        // draw the projected point
        realWorldPoint = context.depthMapRealWorld()[index];
        // don't draw anything if the pixel is part of the background
        if(userMap[index] == 0)
          noStroke(); 
        else{
          // else draw a color based on which user is at that pixel. Change the color every 100 frames.
          //stroke(userClr[ (userMap[index] - 1 + (frameCount / 100)) % userClr.length ]);        
          //stroke(rgbImage.pixels[index]);
          
          
          pushMatrix();
          translate(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);
          
         ////
  zaps();

  ArrayList<Crystal> trash = new ArrayList<Crystal>();
  for (Crystal c : crystals) {
    c.move();
    c.draw();
    if (c.removable)
      trash.add(c);
  }

  for (Crystal c : trash)
    crystals.remove(c);
          //////
          popMatrix();
          
        //point(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);
        pts.add(realWorldPoint.get());//store each point
      }
    } 
  }
 } 
 
 
 
  endShape();
  
  int[] userList = context.getUsers();
  
}
  
  
////
void zaps() {
  for (Crystal c : crystals)
    for (Crystal c2 : crystals) { 
      if (c == c2) continue;
      if (abs(c.loc.x - c2.loc.x) < c.rad*6*(1 + pow(c.power/maxPower - 1, 2))
        && abs(c.loc.y - c2.loc.y) < c.rad*6*(1 + pow(c.power/maxPower - 1, 2))
        || 
        c.bursting 
        && abs(c.loc.x - c2.loc.x) < c.ringRad 
        && abs(c.loc.y - c2.loc.y) < c.ringRad) {          
        doZap(c, c2);
      }
    }
}

void doZap(Crystal crystal, Crystal crystal2) {

  PVector start = crystal.loc;
  PVector end = crystal2.loc;
  PVector diff = PVector.sub(end, start);
  float dist = diff.mag();
  diff.normalize();

  diff.mult(((crystal.power - maxPower/2)+(crystal2.power - maxPower/2))/maxPower);

  if (! crystal.bursting) 
    crystal.acc.sub(diff);
  crystal.power = min(maxPower + 20, crystal.power+2);
  if (crystal.bursting) {
    crystal2.power += crystal.power/20;
    crystal.power *= 0.95;
  }

  strokeWeight(2);
  float numSteps = 5; 
  float lx = start.x;
  float ly = start.y;   
  int i = 0;
  while (i < numSteps && abs (lx - end.x) > 10 || abs(ly - end.y) > 10) {
    float x = lx + (end.x - lx) / numSteps  + random(-9, 9);
    float y = ly + (end.y - ly) / numSteps + random(-9, 9);
    stroke(max(0,min(255,hue(crystal.col) + sin(frameCount*0.05)*50)), 360, 360);
    line(lx, ly, x, y);
    lx = x;
    ly = y;
    i++;
  }
  line(lx, ly, end.x, end.y);
}



class Crystal {

  PVector loc, speed, acc;
  float rad;
  float power;
  int col;
  float ringRad;
  boolean bursting;
  boolean removable;


  public Crystal(float x, float y) {
    this.loc = new PVector(x, y);
    this.speed = new PVector();
    this.acc = new PVector();
    this.rad = 20;
    this.power = maxPower/2;
    this.ringRad = this.rad;
  }


  void move() {

    this.acc.mult(0.4);
    this.speed.mult(0.95);
    this.speed.add(this.acc);
    this.loc.add(this.speed);

    if (this.loc.x <= 0 + this.rad) {
      this.loc.x = this.rad;
      this.acc.x = abs(this.acc.x); 
      this.speed.x = abs(this.speed.x);
    } 
    else if (this.loc.x >= width - this.rad) {
      this.loc.x = width - this.rad;
      this.acc.x = -abs(this.acc.x); 
      this.speed.x = -abs(this.speed.x);
    }
    if (this.loc.y <= 0 + this.rad) {
      this.loc.y = this.rad;
      this.acc.y = abs(this.acc.y); 
      this.speed.y = abs(this.speed.y);
    }
    else if (this.loc.y >= height - this.rad) {
      this.loc.y = height - this.rad;
      this.acc.y = -abs(this.acc.y); 
      this.speed.y = -abs(this.speed.y);
    }

    if (this.power > maxPower && ! this.bursting)
      this.bursting = true;
    if (this.bursting) {
      this.ringRad += 5 + abs((maxRingRad-this.ringRad)/maxRingRad*10);
      this.rad = max(5, this.rad*0.95);
      if (this.ringRad > maxRingRad) {
        this.bursting = false;
        this.removable = true;
      }
    }
    else 
      this.ringRad = this.rad;

    this.power = max(0, this.power-0.5);

    if (this.power <= 0)
      this.removable = true;
  }


  void draw() {

    float b = max(0, (1 - pow((this.power/maxPower-1), 2)) * 360);
    this.col = color(max(0, 200 - this.power/maxPower * 200), 200, b);
    noStroke();   
    fill(this.col);
    ellipse(this.loc.x, this.loc.y, 2*this.rad, 2*this.rad); 
    fill(hue(this.col), saturation(this.col), b/2);
    ellipse(this.loc.x, this.loc.y, this.rad, this.rad); 
    if (this.bursting) {
      noFill();
      strokeWeight(2);
      stroke(hue(this.col), saturation(this.col), max(0, (1-this.ringRad/maxRingRad) * 360));
      ellipse(this.loc.x, this.loc.y, 2*this.ringRad, 2*this.ringRad);
    }
  }
}

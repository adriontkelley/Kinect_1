

void run0(){
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
 
  translate(0,0,-1500);  // set the rotation center of the scene 1000 infront of the camera

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
          
          //lines
    colorMode(HSB); 
  strokeWeight(1.5);
  noFill();
  //lines
  
  
  //lines
  // move attractors
  attractors[0].update();  
  attractors[1].update();
  
  // interact lines with attractors
  float radius = 75*cos(frameCount/150.);
  for(int j = 0; j < l.length; j++) {
    l[j].interact(radius, attractors[0].pos.x, attractors[0].pos.y);
    l[j].interact(-radius, attractors[1].pos.x, attractors[1].pos.y);
    l[j].display();  // display lines
  }
  //lines
          
          popMatrix();
          
        //point(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);
        pts.add(realWorldPoint.get());//store each point
      }
    } 
  }
 } 
 
 
 
  endShape();
  
  int[] userList = context.getUsers();
  //comment out the code that draws the skeleton
  //for(int i=0;i<userList.length;i++)
  //{
    //if(context.isTrackingSkeleton(userList[i]))
      //drawSkeleton(userList[i]);
    
  //}    
 
  
    
  
}

//lines
void initialize() {
  // Create Lines
  float c0 = random(255);
  float c1 = random(255);
  l = new Line[nLines];
  for(int i = 0; i < l.length; i++) {
    float col = lerp(c0, c1, float(i)/l.length);
    l[i] = new Line(10 + 2*i, col);
  }
  //lines
  
  
  
  //lines
  // Create Attractors
  attractors = new Particle[2];
  for (int i = 0; i < attractors.length; i++) {
    attractors[i] = new Particle(random(width), random(height));
    float angle = random(TWO_PI);
    attractors[i].vel.set(cos(angle), sin(angle), 0);
  }
}
//lines


//lines
class Line {
  ArrayList<Particle> p;
  color col;
  int nPoints = 100;
  
  Line(int y, float c) {
    p = new ArrayList<Particle>();
    for (int i = 0; i < nPoints; i++) {
      p.add(new Particle(2+5*i, y));
    }
    
    col = color(c, 100, 255);
  }
  //lines
  
 
  //lines
  void display() {  // display line
    stroke(col);
    beginShape();
    for (int i = 0; i < p.size(); i+=30) {
      curveVertex(p.get(i).pos.x, p.get(i).pos.y);
    }
    endShape();
  }
  //lines
  
 
  //lines
  void interact(float radius, float mx, float my) {  // interact line with attractor
    for (int i = 0; i < p.size(); i++) {
      p.get(i).interact(radius, mx, my);      
    }
    
    //change size of the line when necessary
    for (int i = 0; i < p.size()-1; i++) {
      float d = dist(p.get(i).pos.x, p.get(i).pos.y, p.get(i+1).pos.x, p.get(i+1).pos.y);
      if (d > 5) {  // add a new point when two neighbor points are too far apart
        float x = (p.get(i).pos.x + p.get(i+1).pos.x) / 2;
        float y = (p.get(i).pos.y + p.get(i+1).pos.y) / 2;
        p.add(i+1, new Particle(x, y));
      } else if (d < 1) {  // remove a point when 2 neighbor points are too close
        p.remove(i);
      }
    }   
  }
}
//lines




//lines
class Particle {
  PVector pos, vel, acc;
  
  Particle(float x, float y) {
    pos = new PVector(x, y, 0);
    vel = new PVector(0, 0, 0);
    acc = new PVector(0, 0, 0);
  }
  //lines
 
  
  //lines
  void interact(float r0, float x, float y) {  // interact points with attractors
    float sign = r0/abs(r0);
    r0 = abs(r0);
    
    float r = dist(pos.x, pos.y, x, y);
    float angle = atan2(pos.y-y, pos.x-x);
    
    if (r <= r0) {
      float radius = 0.5*sign*(r0-r)/r0;
      vel.set(radius*cos(angle), radius*sin(angle));
    } else {
      vel.set(0, 0);
    }
    
    pos.add(vel);
  }
  //lines
  
 
  //lines
  void update() {  // move attractors
    //change direction sometimes
    if (random(1) > 0.97) {
      float angle = random(-PI, PI);
      acc.set(cos(angle), sin(angle), 0);
      
      float mod = PVector.angleBetween(acc, vel);
      mod = map(mod, 0, PI, 0.1, 0.001);
      acc.mult(mod); 
    }
    
    // update
    vel.add(acc);
    vel.limit(1.5); 
    pos.add(vel);
    
    // check edges
    pos.x = (pos.x + width)%width;
    pos.y = (pos.y + height)%height;
  }
}
//lines

  
  
  
  

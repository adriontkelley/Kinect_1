void run2(){
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
  int     steps = 150;  // to speed up the drawing, draw every fourth point
  int     index;
  PVector realWorldPoint;
  pts.clear();//reset points
 
  translate(-1000,-500,-200);  // set the rotation center of the scene 1000 infront of the camera

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
  for (int i=ALpoints.size()-1; i>=0; i--) { //for each point in ALpoints, starting from the last
    Point p = ALpoints.get(i); //call the point we're on "p"
    p.move(); //move p
    p.display(); //display p
    //we want to look at two points at once, so let's do another for loop to go through all of our points
    for (int j=ALpoints.size()-1; j>=0; j--) { //for each point in ALpoints, starting from the last
      Point pj = ALpoints.get(j); //call the point we're on "pj"
      float dist=(sqrt(pow((p.x-pj.x),2)+pow((p.y-pj.y),2))); //define "dist" as the distance between p and pj
      if (dist<dbp) { //if the points are close enough together, draw a line between them
      strokeWeight(10);
        stroke(255);
        line(p.x,p.y,pj.x,pj.y);
      }
    }
  }
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
  
  


class Point {
  float x,y,xs,ys;
  Point(float x_,float y_) { //define our point: set our point's values to the inputs
    x=x_;
    y=y_;
    xs=random(-5,5);
    ys=random(-5,5);
  }
  void move(){//move the point, based on speed
    x+=xs;
    y+=ys;
    if (x < 0 || x > width){ //bounce off the walls
      xs=-xs;
    }
    if (y < 0 || y > width){
      ys=-ys;
    }
  }
  void display() { //display the point
    noStroke();
    ellipse(x,y,2,2);
  }
}


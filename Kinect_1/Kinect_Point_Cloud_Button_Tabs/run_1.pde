void run1(){
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
  int     steps = 50;  // to speed up the drawing, draw every fourth point
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
          
         //CircleLinesDistance
     myColor.update();
  for (int j = 0; j < nbCircles; j++)
  {
    circles[j].update();
    for (int k = j+1; k < nbCircles; k++)
    {
      connect(circles[j], circles[k]);
    }
  }
  //CircleLinesDistance
          
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
   

 //CircleLinesDistance
void connect(Circle c1, Circle c2)
{
  float d, x1, y1, x2, y2, r1 = c1.radius, r2 = c2.radius;
  float rCoeff = map(min(abs(r1), abs(r2)), 0, rMax, .08, 1);
  int n1 = c1.nbLines, n2 = c2.nbLines;
  for (int i = 0; i < n1; i++)
  {
    x1 = c1.x + r1 * cos(i * TWO_PI / n1 + c1.theta);
    y1 = c1.y + r1 * sin(i * TWO_PI / n1 + c1.theta);
    for (int j = 0; j < n2; j++)
    {
      x2 = c2.x + r2 * cos(j * TWO_PI / n2 + c2.theta);
      y2 = c2.y + r2 * sin(j * TWO_PI / n2 + c2.theta);

      d = dist(x1, y1, x2, y2);
      if (d < dMin)
      {
        stroke(myColor.R + r2/1.5, myColor.G + r2/2.2, myColor.B + r2/1.5, map(d, 0, dMin, 140, 0) * rCoeff);
        line(x1, y1, x2, y2);
      }
    }
  }
}
//CircleLinesDistance


//CircleLinesDistance
void initialize(Boolean p_random)
{ 
  for (int i = 0; i < nbCircles; i++)
  {
    circles[i] = new Circle(random(rMax), 
    p_random ? random(-width/3, width/3) : 0, 
    p_random ? random(-height/3, height/3) : 0);
  }
  myColor = new MyColor();
}
//CircleLinesDistance


//CircleLinesDistance
class Circle
{
  float x, y, radius, theta = 0;
  int nbLines = (int)random(3, 25);
  float rotSpeed = (random(1) < .5 ? 1 : -1) * random(.005, .034);
  float radSpeed = (random(1) < .5 ? 1 : -1) * random(.3, 1.4);
  
  Circle(float p_radius, float p_x, float p_y)
  {
    radius = p_radius;
    x = p_x;
    y = p_y;
  }

  void update()
  {
    theta += rotSpeed;
    radSpeed *= abs(radius += radSpeed) > rMax ? -1 : 1;
  }
}
//CircleLinesDistance

//CircleLinesDistance
class MyColor
{
  float R, G, B, Rspeed, Gspeed, Bspeed;
  final static float minSpeed = .2;
  final static float maxSpeed = .8;
  MyColor()
  {
    R = random(20, 255);
    G = random(20, 255);
    B = random(20, 255);
    Rspeed = (random(1) > .5 ? 1 : -1) * random(minSpeed, maxSpeed);
    Gspeed = (random(1) > .5 ? 1 : -1) * random(minSpeed, maxSpeed);
    Bspeed = (random(1) > .5 ? 1 : -1) * random(minSpeed, maxSpeed);
  }

  public void update()
  {
    Rspeed = ((R += Rspeed) > 255 || (R < 20)) ? -Rspeed : Rspeed;
    Gspeed = ((G += Gspeed) > 255 || (G < 20)) ? -Gspeed : Gspeed;
    Bspeed = ((B += Bspeed) > 255 || (B < 20)) ? -Bspeed : Bspeed;
  }
}
//CircleLinesDistance


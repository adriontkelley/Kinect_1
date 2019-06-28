/* --------------------------------------------------------------------------
 * SimpleOpenNI User3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * with changes made by Aatish Bhatia 
 * ----------------------------------------------------------------------------
 */
 
 ///Modified by Adrion T. Kelley 2018
 
 ////Works with Processing 2 and Kinect V1
 
 
 
 
 import processing.opengl.*;
import SimpleOpenNI.*;


SimpleOpenNI context;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
float c = 1; 
                                   // the data from openni comes upside down
float        rotY = radians(0);
boolean      autoCalib=true;

boolean recording = false;
ArrayList<PVector> pts = new ArrayList<PVector>();//points for one frame



PVector      bodyCenter = new PVector();
PVector      bodyDir = new PVector();
PVector      com = new PVector();                                   
PVector      com2d = new PVector();                                   
/*color[]       userClr = new color[]{ color(255,255,0),
                                     color(0,255,255),
                                     color(255,0,255),
                                     color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255)
                                   };
*/



int page = 0;


//lines
int nLines = 50;
Line[] l;
Particle[] attractors;
//lines



//CircleLinesDistance
int nbCircles = 8;
Circle[] circles;
MyColor myColor;
float rMax, dMin;
//CircleLinesDistance





///Points
float dbp=100; //distance between points

ArrayList<Point> ALpoints; //preps for creation an arraylist of points
///Points


///Crystal
ArrayList<Crystal> crystals;
Crystal dragged;
float maxPower = 100;
int maxCrystals = 10;
float maxRingRad;

///Crystal


void setup(){
  //size(1500,900, P3D);
  frameRate(10);
  size(1500,900,OPENGL);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }

  // disable mirror
  context.setMirror(true);

  // enable depthMap generation 
  context.enableDepth();

  //context.enableRGB();


  // enable skeleton generation for all joints
  context.enableUser();

  stroke(255,255,255);
  smooth();  
  perspective(radians(45),
              float(width)/float(height),
              10,150000);
              
  
  
  //lines
  initialize();
  //lines  
 
  
    //CircleLinesDistance
  rMax = min(width, height)/2;
  dMin = max(width, height)/3.5;
  circles = new Circle[nbCircles];
  initialize(false);
  //CircleLinesDistance
  
  
   /// Points
          ALpoints = new ArrayList<Point>(); //creates that arraylist
  for (int i=0; i<75; i++){ 
    ALpoints.add(new Point(random(0,width),random(0,height))); //fills it with 75 points at random locations
  }
  
  ///Points
  
  
   /// Crystal
         colorMode(HSB, 360);
         crystals = new ArrayList<Crystal>();
  maxRingRad = width/4.0;
  for(int i = 0; i < 3; i++)
    crystals.add(new Crystal(width/2 - 110 + i * 110, height/2 - 110 + i%2 * 110));
  
  ///Crystal
  
  
}




void draw() {
  //fill(255);
  //textSize(30);
  //fill(0, 9);
  //rect(0,0,width,height);
  if(page == 0) run0();
  else if(page == 1) run1(); 
  else if(page == 2) run2();
  else if(page == 3) run3();
  
  
 
  
 
  
  
}






void mousePressed(){
 // page = round(random(4));
  //floor = round down
  //ceil = round up
  
  
}


void keyPressed(){
  if(key == '1') page = 0;
  else if(key == '2') page = 1;
  else if(key == '3') page = 2;
  else if(key == '4') page = 3;
 
  
}


// draw the skeleton with the selected joints
void drawSkeleton(int userId){
  strokeWeight(3);

  // to get the 3d joint data
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  

  // draw body direction
  getBodyDirection(userId,bodyCenter,bodyDir);
  
  bodyDir.mult(200);  // 200mm length
  bodyDir.add(bodyCenter);
  
  stroke(255,200,200);
  line(bodyCenter.x,bodyCenter.y,bodyCenter.z,
       bodyDir.x ,bodyDir.y,bodyDir.z);

  strokeWeight(1);
 
}

void drawLimb(int userId,int jointType1,int jointType2){
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  float  confidence;
  
  // draw the joint position
  confidence = context.getJointPositionSkeleton(userId,jointType1,jointPos1);
  confidence = context.getJointPositionSkeleton(userId,jointType2,jointPos2);

  stroke(255,0,0,confidence * 200 + 55);
  line(jointPos1.x,jointPos1.y,jointPos1.z,
       jointPos2.x,jointPos2.y,jointPos2.z);
  
  drawJointOrientation(userId,jointType1,jointPos1,50);
}

void drawJointOrientation(int userId,int jointType,PVector pos,float length){
  // draw the joint orientation  
  PMatrix3D  orientation = new PMatrix3D();
  float confidence = context.getJointOrientationSkeleton(userId,jointType,orientation);
  if(confidence < 0.001f) 
    // nothing to draw, orientation data is useless
    return;
    
  pushMatrix();
    translate(pos.x,pos.y,pos.z);
    
    // set the local coordsys
    applyMatrix(orientation);
    
    // coordsys lines are 100mm long
    // x - r
    stroke(255,0,0,confidence * 200 + 55);
    line(0,0,0,
         length,0,0);
    // y - g
    stroke(0,255,0,confidence * 200 + 55);
    line(0,0,0,
         0,length,0);
    // z - b    
    stroke(0,0,255,confidence * 200 + 55);
    line(0,0,0,
         0,0,length);
  popMatrix();
}


// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curContext,int userId){
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  context.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext,int userId){
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext,int userId){
  //println("onVisibleUser - userId: " + userId);
}




void getBodyDirection(int userId,PVector centerPoint,PVector dir){
  PVector jointL = new PVector();
  PVector jointH = new PVector();
  PVector jointR = new PVector();
  float  confidence;
  
  // draw the joint position
  confidence = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,jointL);
  confidence = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,jointH);
  confidence = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,jointR);
  
  // take the neck as the center point
  confidence = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,centerPoint);
  
  /*  // manually calc the centerPoint
  PVector shoulderDist = PVector.sub(jointL,jointR);
  centerPoint.set(PVector.mult(shoulderDist,.5));
  centerPoint.add(jointR);
  */
  
  PVector up = PVector.sub(jointH,centerPoint);
  PVector left = PVector.sub(jointR,centerPoint);
    
  dir.set(up.cross(left));
  dir.normalize();
}







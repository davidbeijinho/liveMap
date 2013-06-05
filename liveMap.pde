import codeanticode.syphon.*;
import SimpleOpenNI.*;

PGraphics canvas;
SyphonServer server;
SimpleOpenNI context;

float        zoomF =0.5f;
float        rotX = radians(180);  
float        rotY = radians(0);
float        rotZ = radians(0);
color[]      userColors =    { color(0,255,0) };
color[]      userCoMColors = { color(0,255,0) };

void setup()
{
  size(displayWidth, displayHeight, OPENGL);

  canvas = createGraphics(displayWidth, displayHeight, OPENGL);
  server = new SyphonServer(this, "Processing LiveMap");

  context = new SimpleOpenNI(this);
  context.setMirror(false);

  if(context.enableDepth() == false)
  {
    println("PROBLEMAS"); 
    exit();
    return;
  }

  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  context.enableScene();

  stroke(255,255,255);
  smooth();  
  perspective(radians(45),
    float(width)/float(height),10,150000);
}

void draw()
{
  canvas.beginDraw();

  context.update();
  canvas.background(0,0,0);

  canvas.translate(width/2, height/2, 0);
  canvas.rotateX(rotX);
  canvas.rotateY(rotY);
  canvas.rotateZ(rotZ);
  canvas.scale(zoomF);

  int[]   depthMap = context.depthMap();
  int     steps   = 3;
  int     index;
  PVector realWorldPoint;

  canvas.translate(0,0,-1000);

  int userCount = context.getNumberOfUsers();
  int[] userMap = null;
  if(userCount > 0)
  {
    userMap = context.getUsersPixels(SimpleOpenNI.USERS_ALL);
  }

  for(int y=0;y < context.depthHeight();y+=steps)
  {
    for(int x=0;x < context.depthWidth();x+=steps)
    {
      index = x + y * context.depthWidth();
      if(depthMap[index] > 0)
      { 
        realWorldPoint = context.depthMapRealWorld()[index];
        if(userMap != null && userMap[index] != 0)
        {
          int colorIndex = userMap[index] % userColors.length;
          canvas.strokeWeight(7);
          canvas.stroke(userColors[colorIndex]); 
        }
        else
        {
          canvas.noStroke();
          canvas.stroke(0);
        } 
        canvas.point(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);
      }
    } 
  } 


  context.drawCamFrustum();
  canvas.endDraw();
  image(canvas, 0, 0);
  server.sendImage(canvas);
}

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);  
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void keyPressed()
{
  switch(key)
  {
    case ' ':
    context.setMirror(!context.mirror());
    break;
  }
  switch(keyCode)
  {
    case LEFT:
    if(keyEvent.isShiftDown())
      rotZ+=0.01f;
    else
      rotY += 0.01f;
    break;
    case RIGHT:
    if(keyEvent.isShiftDown())
      rotZ-=0.01f;
    else
      rotY -= 0.01f;
    break;
    case UP:
    if(keyEvent.isShiftDown())
      zoomF += 0.001f;
    else
      rotX += 0.01f;
    break;
    case DOWN:
    if(keyEvent.isShiftDown())
    {
      zoomF -= 0.01f;
      if(zoomF < 0.01)
        zoomF = 0.001;
    }
    else
      rotX -= 0.01f;
    break;
  }

  println("RX-> "+rotX+" RY-> "+rotY+" RZ-> "+rotZ+" ZOOM-> "+zoomF);
}

//boolean sketchFullScreen() {
//  return true;
//}
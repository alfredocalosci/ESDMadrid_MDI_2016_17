// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Example 16-11: Simple color tracking

// video
import processing.video.*;

// keystone
import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface, surface2;
PGraphics offscreen, offscreen2;

// Variable for capture device
Capture video;

// A variable for the color we are searching for.
color trackColor; 

boolean vMode = true;
int yOffset = 320;

void setup() {
   size(800, 600, P3D);
  video = new Capture(this, 320, 240);
  video.start();
  
  // Start off tracking for red
  trackColor = color(255, 0, 0);
  
  // keystone objects
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(300, 300, 20);
  offscreen = createGraphics(300, 300, P3D);
  surface2 = ks.createCornerPinSurface(300, 300, 20);
  offscreen2 = createGraphics(300, 300, P3D);
}

void captureEvent(Capture video) {
  // Read image from the camera
  video.read();
}

void draw() {
   background(0);
   
  video.loadPixels();
  
  if(vMode){
    image(video, 0, yOffset);
  }

  // Before we begin searching, the "world record" for closest color is set to a high number that is easy for the first pixel to beat.
  float worldRecord = 500; 

  // XY coordinate of closest color
  int closestX = 0;
  int closestY = 0;

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      int loc = x + y*video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      // Using euclidean distance to compare colors
      float d = dist(r1, g1, b1, r2, g2, b2); // We are using the dist( ) function to compare the current color with the color we are tracking.

      // If current color is more similar to tracked color than
      // closest color, save current location and current difference
      if (d < worldRecord) {
        worldRecord = d;
        closestX = x;
        closestY = y + yOffset;
      }
    }
  }

  // We only consider the color found if its color distance is less than 10. 
  // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.
  if (worldRecord < 10) { 
    // Draw a circle at the tracked pixel
    fill(trackColor);
    // strokeWeight(4.0);
    stroke(0);
    ellipse(closestX, closestY, 16, 16);
  }
  
  PVector surfaceMouse = surface.getTransformedMouse();
  PVector surfaceMouse2 = surface2.getTransformedMouse();
  
  // Draw the scene, offscreen
  offscreen.beginDraw();
  offscreen.background(255);
  offscreen.fill(0, 255, 0);
  offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 75, 75);
  offscreen.endDraw();
  
    // Draw the scene, offscreen
  offscreen2.beginDraw();
  offscreen2.background(255);
  offscreen2.fill(0, 255, 0);
  offscreen2.ellipse(surfaceMouse2.x, surfaceMouse2.y, 75, 75);
  offscreen2.endDraw();
  
  // render the scene, transformed using the corner pin surface
  surface.render(offscreen);
  surface2.render(offscreen2);
  
  
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  // int loc = mouseX + mouseY*video.width;
  
  int loc = 0;
  
  if(mouseX <= 320){
     loc = mouseX + (mouseY-yOffset)*video.width;
  }

  int maxL = 320 * 240;
  
  if(loc >= 0 && loc < maxL ){
    trackColor = video.pixels[loc];
  }
  
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
    
   case 'v':
    // saves the layout
    vMode = !vMode;
    break;
  }
  
}
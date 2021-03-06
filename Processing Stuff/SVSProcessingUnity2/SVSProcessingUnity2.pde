import oscP5.*;
import netP5.*;
import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;
//import processing.video.*;

//Osc
Capture cam1, cam2;
OscP5 oscP5;
NetAddress myBroadcastLocation;

//OpenCV
OpenCV opencv;
PImage src, dst;
ArrayList<Contour> contours;
ArrayList<Contour> newBlobContours;// List of detected contours parsed as blobs (every frame)
ArrayList<Blob> blobList;
float contrast = .9;
int blobSizeThreshold = 20;
int threshold = 185;
int blurSize = 4;
int blobCount = 0;

void setup() {
  size(1280, 960);
  blobList = new ArrayList<Blob>();
  // frameRate(20);
  oscP5 = new OscP5(this, 12000);
  myBroadcastLocation = new NetAddress("127.0.0.1", 8000);

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    cam1 = new Capture(this, cameras[1]);
    cam1.start();

    cam2 = new Capture(this, cameras[89]);
    cam2.start();
  }  
  //delay(250);
  opencv = new OpenCV(this, 1280, 480);
  noStroke();
  smooth();
}

void draw() {

  if (cam1.available() == true && cam2.available() == true) {
    cam1.read();
    cam2.read();
    
  
    //image(cam, 0, 0);
    //src = cam1

    PGraphics output = createGraphics(1280, 480, JAVA2D);
    output.beginDraw();
    output.image(cam1, 640, 0);
    output.image(cam2, 0, 0);
    output.endDraw();
    image(output, 0, 480);

    //loadPixels();
    //temp = output.get(); 

    opencv.loadImage(output.get());
    src = opencv.getSnapshot();

    opencv.gray();
    opencv.contrast(contrast);
    opencv.threshold(threshold);

    opencv.dilate();
    opencv.erode();

    opencv.blur(blurSize);

    dst = opencv.getOutput();

    detectBlobs();
    //contours = opencv.findContours();
    //println("found " + contours.size() + " contours");

    //scale(.5);
    displayBlobs();
    image(src, 0, 0);
    //image(dst, src.width, 0);
    displayBlobs();
    //    filter(THRESHOLD, .5);

    //print(blobList.size());
    for (int i = 0; i < blobList.size(); i++) {
      if (!blobList.get(i).dead()) {
        //print("im alive");
        Rectangle r = blobList.get(i).getBoundingBox();
        sendMessage(r.x, r.y, r.width*r.height, blobList.get(i).id);
        //print("squared: " ,r.width*r.height);
      }
    }


    noFill();
    strokeWeight(3);

    for (Contour contour : contours) {
      stroke(0, 255, 0);
      contour.draw();

      stroke(255, 0, 0);
      beginShape();
      for (PVector point : contour.getPolygonApproximation().getPoints()) {
        vertex(point.x, point.y);
      }
      endShape();
    }
    text("Framerate: " + int(frameRate), 10, 450);
  }
}

void sendMessage(int xx, int zz, int area, int id) {

  float mappedX = map(xx, 1280, 0, 10, 85);
  float mappedZ = map(zz, 0, 480, 40, 4);
  float mappedArea = map(area, 500, 16000, 1, 10);//check med blobs
  //println(xx, zz, area, mappedX, mappedZ, mappedArea);
  //drawText(mappedX, mappedZ, mappedArea, xx, zz);

  OscMessage myOscMessage = new OscMessage("/positionData");
  myOscMessage.add(mappedX);
  myOscMessage.add(mappedZ);
  myOscMessage.add(mappedArea);
  myOscMessage.add(id);
  print(id);
  oscP5.send(myOscMessage, myBroadcastLocation);
}

/*void sendMessage(int x, int z, int area, int num) {
 float mappedX = map(x, 0, 640, 21, 107);
 float mappedZ = map(z, 0, 480, 83, 44);
 float mappedArea = map(area, 500, 16000,1,10);
 
 OscMessage myOscMessage = new OscMessage("/positionData");
 myOscMessage.add(mappedX);
 myOscMessage.add(mappedZ);
 myOscMessage.add(mappedArea);
 //myOscMessage.add(num);
 oscP5.send(myOscMessage, myBroadcastLocation);
 }*/

void displayContoursBoundingBoxes() {

  for (int i=0; i<contours.size(); i++) {

    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();

    if (//(contour.area() > 0.9 * src.width * src.height) ||
      (r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      continue;

    stroke(255, 0, 0);
    fill(255, 0, 0, 150);
    strokeWeight(2);
    rect(r.x, r.y, r.width, r.height);
  }
}

////////////////////
// Blob Detection
////////////////////

void detectBlobs() {

  // Contours detected in this frame
  // Passing 'true' sorts them by descending area.
  contours = opencv.findContours(true, true);

  newBlobContours = getBlobsFromContours(contours);

  //println(contours.length);

  // Check if the detected blobs already exist are new or some has disappeared. 

  // SCENARIO 1 
  // blobList is empty
  if (blobList.isEmpty()) {
    // Just make a Blob object for every face Rectangle
    for (int i = 0; i < newBlobContours.size(); i++) {
      println("+++ New blob detected with ID: " + blobCount);
      blobList.add(new Blob(this, blobCount, newBlobContours.get(i)));
      blobCount++;
    }

    // SCENARIO 2 
    // We have fewer Blob objects than face Rectangles found from OpenCV in this frame
  } else if (blobList.size() <= newBlobContours.size()) {
    boolean[] used = new boolean[newBlobContours.size()];
    // Match existing Blob objects with a Rectangle
    for (Blob b : blobList) {
      // Find the new blob newBlobContours.get(index) that is closest to blob b
      // set used[index] to true so that it can't be used twice
      float record = 50000;
      int index = -1;
      for (int i = 0; i < newBlobContours.size(); i++) {
        float d = dist(newBlobContours.get(i).getBoundingBox().x, newBlobContours.get(i).getBoundingBox().y, b.getBoundingBox().x, b.getBoundingBox().y);
        //float d = dist(blobs[i].x, blobs[i].y, b.r.x, b.r.y);
        if (d < record && !used[i]) {
          record = d;
          index = i;
        }
      }
      // Update Blob object location
      used[index] = true;
      b.update(newBlobContours.get(index));
    }
    // Add any unused blobs
    for (int i = 0; i < newBlobContours.size(); i++) {
      if (!used[i]) {
        println("+++ New blob detected with ID: " + blobCount);
        blobList.add(new Blob(this, blobCount, newBlobContours.get(i)));
        //blobList.add(new Blob(blobCount, blobs[i].x, blobs[i].y, blobs[i].width, blobs[i].height));
        blobCount++;
      }
    }

    // SCENARIO 3 
    // We have more Blob objects than blob Rectangles found from OpenCV in this frame
  } else {
    // All Blob objects start out as available
    for (Blob b : blobList) {
      b.available = true;
    } 
    // Match Rectangle with a Blob object
    for (int i = 0; i < newBlobContours.size(); i++) {
      // Find blob object closest to the newBlobContours.get(i) Contour
      // set available to false
      float record = 50000;
      int index = -1;
      for (int j = 0; j < blobList.size(); j++) {
        Blob b = blobList.get(j);
        float d = dist(newBlobContours.get(i).getBoundingBox().x, newBlobContours.get(i).getBoundingBox().y, b.getBoundingBox().x, b.getBoundingBox().y);
        //float d = dist(blobs[i].x, blobs[i].y, b.r.x, b.r.y);
        if (d < record && b.available) {
          record = d;
          index = j;
        }
      }
      // Update Blob object location
      Blob b = blobList.get(index);
      b.available = false;
      b.update(newBlobContours.get(i));
    } 
    // Start to kill any left over Blob objects
    for (Blob b : blobList) {
      if (b.available) {
        b.countDown();
        if (b.dead()) {
          b.delete = true;
        }
      }
    }
  }
}

ArrayList<Contour> getBlobsFromContours(ArrayList<Contour> newContours) {

  ArrayList<Contour> newBlobs = new ArrayList<Contour>();

  // Which of these contours are blobs?
  for (int i=0; i<newContours.size(); i++) {

    Contour contour = newContours.get(i);
    Rectangle r = contour.getBoundingBox();

    if (//(contour.area() > 0.9 * src.width * src.height) ||
      (r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      continue;

    newBlobs.add(contour);
  }

  return newBlobs;
}

void displayBlobs() {

  for (Blob b : blobList) {
    strokeWeight(1);
    b.display();
  }
}

/*int brightestX = 0; // X-coordinate of the brightest video pixel
 int brightestY = 0; // Y-coordinate of the brightest video pixel
 float brightestValue = 100; // Brightness of the brightest video pixel
 // Search for the brightest pixel: For each row of pixels in the video image and
 // for each pixel in the yth row, compute each pixel's index in the video
 cam.loadPixels();
 int index = 0;
 boolean changes = false;
 for (int y = 0; y < cam.height; y++) 
 {
 for (int x = 0; x < cam.width; x++) 
 {
 // Get the color stored in the pixel
 int pixelValue = cam.pixels[index];
 // Determine the brightness of the pixel
 float pixelBrightness = brightness(pixelValue);
 // If that value is brighter than any previous, then store the
 // brightness of that pixel, as well as its (x,y) location
 if (pixelBrightness > brightestValue) 
 {
 brightestValue = pixelBrightness;
 brightestY = y;
 brightestX = x;
 sendMessage(x, y);
 changes = true;
 //println("Brightness value = " + pixelBrightness);
 //println("X = " + x);
 //println("Y = " + y);
 }
 index++;
 }
 
 // Draw a large, yellow circle at the brightest pixel
 fill(255, 204, 0, 128);
 ellipse(brightestX, brightestY, 50, 50);
 
 
 fill(255);
 text("Framerate: " + int(frameRate), 10, 450);
 }
 if (!changes) {
 sendMessage(0, 0);
 }*/


// The following does the same, and is faster when just drawing the image
// without any additional resizing, transformations, or tint.
//set(0, 0, cam);
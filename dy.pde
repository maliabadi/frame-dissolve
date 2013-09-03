import processing.video.*;

int movFrameRate = 30;
Movie mov;

// increments every time a new frame is loaded
int frameCounter = 1;

// increments on every loop, tracks how severe
// the dissolve effect should be given the current time
int tick = 1;

// the granularity, in pixels, of the dissolve
// a larger cellsize will result in a more
// chunky, pixelated dissolve effect
int cellsize = 2;

// how long a frame is in seconds 
float frameDuration;

int columns;
int rows;

// the width of the first frame of the movie
int frameWidth;

// the height of the first frame of the movie
int frameHeight;

// the frame number at which the script stops
// attempting to load subsequent frames
int lastFrame;

void setup() {
  frameDuration = 1.0 / movFrameRate;
  size(960, 480, P3D);
  background(255, 255, 255);
  mov = new Movie(this, "singleladies.mov");
  mov.play();
  // lastFrame can only be declared
  // after mov.play() is called. The instatiated
  // doesn't have  a duration until play()
  lastFrame = int(movFrameRate * mov.duration());
  mov.jump(0);
  frameHeight = mov.height;
  frameWidth = mov.width;
  columns = frameWidth / cellsize;
  rows = frameHeight / cellsize;
  mov.pause();
}

float getWhere(int n){
  float where = (n + 0.5) * frameDuration; 
  float diff = mov.duration() - where;
  if (diff < 0) {
    where += diff - 0.25 * frameDuration;
  }
  return where;
}

void setFrame() {
  mov.loop();
  mov.jump(getWhere(frameCounter));
  mov.pause();
}

void movieEvent(Movie m) {
  m.read();
}

color getPixel(int x, int y){
   int loc = x + y*frameWidth;
   color c = mov.pixels[loc];
   return c;
}

float dissolve(color pixel){
  // this function is the primary point of customization
  // by default, sets z as a function of the tick 
  // and the darkness of the given pixel
  float z = ((tick * 15) / float(width)) * (brightness(pixel) * -1) - 20.0;
  return z;
}

color fade(color pixel){
  // modify this function to change the way in which
  // the clip fades, or whether it fades at all
  // by default it's set to fade to white by the end of
  // the clip  
  color fadeTo = color(255, 255, 255);
  float fadeAmount = float(frameCounter) / lastFrame; 
  return lerpColor(pixel,  fadeTo, fadeAmount);
}

void draw() {
  // saves each frame as a jpeg, so the result
  // can be sewn together into a .mov, and display 
  // at the movie's original rate
  saveFrame("line-######.jpg");
  tick += 1;
  frameCounter += 1;
  background(255, 255, 255);
  setFrame();
  mov.loadPixels();
  // iterate over every column of cells  
  for ( int i = 0; i < columns; i++) {
    // iterate over every row of cells
    for ( int j = 0; j < rows; j++) {
      int x = i * cellsize + cellsize / 2;
      int y = j * cellsize + cellsize / 2;
      color c = getPixel(x, y);
      float z = dissolve(c);
      pushMatrix();
      translate(x, y, z);
      fill(fade(c));
      noStroke();
      rectMode(CENTER);
      rect(0, 0, cellsize, cellsize);
      popMatrix();
    }
  }
}

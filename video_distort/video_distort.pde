import processing.video.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress receiver;

// Size of each cell in the grid, ratio of window size to mov size
int movScale = 2;
//int movScale;
// Number of columns and rows in the system
int cols, rows;
// Step 1. Declare a Movie object.
Movie movie;
boolean hasPixels = false;

float OldRange, NewRange, NewValue, NewMax, NewMin, OldMax, OldMin;

float movSpeed = 1;

void setup() {
    //size(1280, 720);
    fullScreen();
  // Initialize columns and rows
  // Step 2. Initialize Movie object. The file "testmovie.mov" should live in the data folder.
  
  movie = new Movie(this, "FinalVideo050422.mp4");
  // Step 3. Start playing movie. To play just once play() can be used instead.
  movie.loop();
  
  oscP5 = new OscP5( this , 6001 );
  receiver = new NetAddress( "127.0.0.1" , 6001 );     
}

// Step 5. Display movie.
void draw() {
  //movie.loadPixels();
  // Begin loop for columns
  if( hasPixels ){
    for (int i = 0; i < cols; i++) {
        // Begin loop for rows
      for (int j = 0; j < rows; j++) {
        // Where are you, pixel-wise?
        int x = i*movScale;
        int y = j*movScale;
        
        //println( x + " " + y ) ; 
        color c;
        if (x + y*movie.width >= movie.pixels.length) {
          c = movie.pixels[movie.pixels.length - 1];    
        }
        else {
          c = movie.pixels[x + y*movie.width]; 
        }
        
        fill(c);
        stroke(0);
        rect(x, y, movScale, movScale);
        }
      }
    //println( "has Pixels " ); 
  }
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  movie.read();
  movie.loadPixels();
  hasPixels = true;
}

void oscEvent( OscMessage m ) {
//  //print( "Received an osc message" );
//  //print( ", address pattern: " + m.addrPattern( ) );
//  //print( ", typetag: " + m.typetag( ) );
//  //if(m.addrPattern( ).equals("/abstraction") && m.typetag().equals("i")) {
//  //  /* transfer receivd values to local variables */
//  //  temp = m.get(0);
//  //  println(temp);
//  //}
  
  if(m.checkAddrPattern("/abstraction")==true) {
    /* check if the typetag is the right one. */
    if(m.checkTypetag("i")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      movScale = m.get(0).intValue();  
      print("### received an osc message /abstraction with typetag i.");
      println(" values: "+movScale);
    }  
  }
  OldMax = (1.0/2.0);
  OldMin = (1.0/80.0);
  
  OldRange = (OldMax - OldMin);
  NewMax = 1.0;
  NewMin = 0.75;
  NewRange = (NewMax - NewMin);  
  NewValue = (((1.0/movScale - OldMin) * NewRange) / OldRange) + NewMin;
  println("movie speed: " + NewValue);
  movie.speed(NewValue);
  
  cols = width/movScale;
  rows = height/movScale;
  
  println();
}

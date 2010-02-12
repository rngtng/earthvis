/**
 * Viuslaizing qype reviews via time on the globe
 *
 */
 
import processing.opengl.*; 
import peasy.*;
import de.bezier.data.sql.*;
import javax.media.opengl.GL;
import com.hardcorepawn.*;

String DB_USER = "root";
String DB_PASS = "";
String DB_NAME = "earthvis";
String DB_HOST = "127.0.0.1";

PeasyCam cam;
Ellipsoid earth;

MySQL con;

int SPHERE_RADIUS = 100;
int AXIS_SIZE = SPHERE_RADIUS+20;
int ANZ = 50000;

ArrayList points;
ArrayList reviews;

HScrollbar hs;

void setup() {
  size(800, 800, OPENGL); 
  points = new ArrayList();
  
  cam = new PeasyCam(this, AXIS_SIZE+150);

  hs = new HScrollbar(10, height-30, width-20, 10, 6);
 // cam.setMinimumDistance(AXIS_SIZE);

  con = new MySQL( this, DB_HOST, DB_NAME, DB_USER, DB_PASS );
  if( !con.connect() ) {
    println("couldn't connect to DB: " + DB_HOST + " " + DB_NAME + " " + DB_USER);
    exit();
  }

  earth = new Ellipsoid(this, 50, 50);
  earth.setTexture("earth.jpg");
  earth.setRadius(SPHERE_RADIUS);
  earth.moveTo(new PVector(0,0,0));
  earth.rotateBy(radians(90), radians(90), 0);
    
  review_find(this, ANZ);
   
  println("loaded");
}

boolean drawAxis = true;
boolean drawGlobe = true;
boolean drawNet = false;

//#################################################
int cnt = 0;

void draw() {
  rotateY(-PI);
 // if(!hs.locked) hs.setPos( float(cnt) / points.size() );
  background(0);  
  
  cam.beginHUD();
  pointLight(255, 205, 255, 500, 500, 700);
  cam.endHUD();    
 
  if( drawAxis) draw_xyz(AXIS_SIZE);
  if( drawNet) draw_net(SPHERE_RADIUS, 9);  
  if( drawGlobe) earth.draw();
  
  int cnt = floor(hs.getPos() * points.size());
  draw_points( cnt );
     
  cam.setMouseControlled(!hs.locked);
  
  cam.beginHUD();
  draw_line();
  cam.endHUD();
  
//  cnt = ceil(hs.getPos() * points.size()) + 2;
  //if( cnt > points.size()) cnt = 0;
}


//############################################

void draw_points() {
  draw_points(-1);
}

void draw_points( int anz ) {
  Iterator itr = points.iterator();
  while(itr.hasNext()) {
    if( anz  < 1 ) return;
    SuperPoint r = (SuperPoint) itr.next();
    r.draw(1);
    anz--;
  } 
}

//############################################

void draw_xyz(float nsize) {
  //X - Red
  stroke(#ff0000);
  line(-nsize,0,nsize,0);
  
  //Y - Blue
  stroke(#0000ff);  
  line(0,-nsize,0,nsize);

  //Y - Green
  rotateX(-PI/2.0);
  stroke(#00ff00);
  line(0,-nsize,0,nsize);
  
  rotateX(PI/2.0);
}

void draw_net(float nsize, int anz) {
  noFill();
  for( float z = 0; z < anz; z += 1) {
    rotateY(PI/anz);
    //vertival
    stroke(90);
    ellipse(0, 0, nsize*2, nsize*2);
    float t = nsize / anz * z;
    float s = 2 * sqrt( sq(nsize) - sq(t) );
    float r = PI/2;
    //horizontal
    // actually should be by angle NOT height
    stroke(90);
    rotateX(r);
    translate(0, 0, t);    
    ellipse(0, 0, s, s);    
    translate(0, 0, -t * 2);    
    ellipse(0, 0, s, s);    
    translate(0, 0, t);
    rotateX(-r);
  }
  rotateY(-PI);
}

void draw_line() {
  stroke(#FFFFFF);
  hs.update();
  hs.display();
}


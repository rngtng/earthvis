/**
 * Viuslaizing qype reviews via time on the globe
 *
 */
 
import processing.opengl.*; 
import peasy.*;
import de.bezier.data.sql.*;
import javax.media.opengl.GL;
import com.hardcorepawn.*;




de.bezier.data.sql.SQLite con;
PeasyCam cam;

SuperPoint t;

String DB_USER = "root";
String DB_PASS = "";
String DB_NAME = "earthvis";
String DB_HOST = "127.0.0.1";

Ellipsoid earth;

PGraphicsOpenGL pgl;
GL gl;

MySQL con2;

int SPHERE_RADIUS = 95;
int AXIS_SIZE = SPHERE_RADIUS+20;
int ANZ = 500; //000;

ArrayList reviews;
ArrayList locators;

HScrollbar hs;

void setup() {
  size(800,800,OPENGL); 
  cam = new PeasyCam(this, AXIS_SIZE+150);

  hs = new HScrollbar(10, height-30, width-20, 10, 6);
 // cam.setMinimumDistance(AXIS_SIZE);
  
  t = new SuperPoint(this);

  con2 = new MySQL( this, DB_HOST, DB_NAME, DB_USER, DB_PASS );
  if( !con2.connect() ) {
    println("couldn't connect to DB: " + DB_HOST + " " + DB_NAME + " " + DB_USER);
    exit();
  }

  earth = new Ellipsoid(this, 50, 50);
  earth.setTexture("earth.jpg");
  earth.setRadius(SPHERE_RADIUS);
  earth.moveTo(new PVector(0,0,0));
  earth.rotateBy(0, radians(90), 0);
  
  /* con = new de.bezier.data.sql.SQLite( this, "copy.rdb" );  // open database file
  if ( !con.connect() )
  {
    println("couldn't connect to Local DB");
    exit();      
  } */
  
  reviews = review_find(ANZ);
   
  println("loaded");
}

boolean drawAxis = true;
boolean drawSphere = false;
boolean drawGlobe = true;
boolean drawNet = false;

//#################################################
int cnt = 0;

void draw() {
  if(!hs.locked) hs.setPos( float(cnt) / reviews.size() );
  background(0);  
  
  cam.beginHUD();
  pointLight(255, 255, 255, 700, 700, 700);
  cam.endHUD();    
  
  
  if( drawAxis) draw_xyz(AXIS_SIZE);
  if( drawNet) draw_net(SPHERE_RADIUS, 9);  
  if( drawSphere) draw_sphere(SPHERE_RADIUS);
  if( drawGlobe) earth.draw();
  
  draw_reviews();
     
  cam.setMouseControlled(!hs.locked);
  
  cam.beginHUD();
  draw_line();
  cam.endHUD();
  
  cnt = ceil(hs.getPos() * reviews.size()) + 2;
  if( cnt > reviews.size()) cnt = 0;
}

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

void draw_sphere(float nsize) {
   fill(255);
   noStroke();  
   sphere(nsize);    
}

void draw_line() {
  stroke(#FFFFFF);
  hs.update();
  hs.display();
}

void draw_box() {
  noFill();
  box(SPHERE_RADIUS*2);
}

void draw_point( float x, float y, float z, color c ) {
  stroke(c); 
  rotateX(PI/2);  
  translate(x, -y, -z);
  point(0,0);
  translate(-x, y, z);
  rotateX(-PI/2);  
}

//############################################
void draw_reviews() {
  Iterator itr = reviews.iterator();
  int i = floor(hs.getPos() * reviews.size());
  color c;
  while(itr.hasNext()) {
  Review r = (Review) itr.next();
    switch( r.stars ) {
      case 1:
           c = #FF0000; break;
      case 2:
            c = #DD1111; break;
      case 3:
            c = #FFFF00; break;
      case 4: 
            c = #99FF00; break;
      case 5:
            c = #00FF00; break;
      default: 
           c = #0000FF; break;              
    }
    draw_point(r.x, r.y, r.z, c );
    i--;
    if( i < 1 ) return;
  } 
}


void draw_locators() {
  Iterator itr = locators.iterator();

  while(itr.hasNext()) {
  Locator r = (Locator) itr.next();
  //  draw_ll(r.lat, r.lng, r.c);
  } 
}

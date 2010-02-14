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

float speed = 1;
float speed_step = 0.001;

int SPHERE_RADIUS = 1000;
int AXIS_SIZE = ceil(SPHERE_RADIUS * 1.2);
int LIMIT = 500000;

ClusteredPoints points;
HScrollbar hs;

boolean drawAxis = true;
boolean drawGlobe = true;
boolean drawNet = false;
boolean running = false;

void setup() {
  size(800, 800, OPENGL); 
  
  PFont font;
  font = loadFont("Calibri-32.vlw"); 
  textFont(font, 16); 
  
  cam = new PeasyCam(this, AXIS_SIZE+350);
  cam.setMinimumDistance(SPHERE_RADIUS+10);
  cam.setMaximumDistance(5*AXIS_SIZE);
 
  hs = new HScrollbar(10, height-30, width-20, 10, 3); //x, y, width, height, loosness
  hs.setPos( 0); 

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
    
  points = new ClusteredPoints(this, SPHERE_RADIUS / 100);
  points.setLimit(LIMIT);
  //points.setConditions("domain_id LIKE 'de%'");
 // points.setConditions("login = 'rausauskl'");
  points.load();
     
  println("init done");
}

//#################################################

void draw() {  
  rotateX(-PI/2);
  rotateX(-PI/4);
  
  if(running) {
    if(!hs.locked) hs.setPos( hs.getPos() + speed * speed_step );
    if(hs.getPos() > 1) hs.setPos( 0 );
  }
  background(0);  
  
  cam.beginHUD();
  pointLight(255, 205, 255, 500, 500, 700);
  cam.endHUD();    
 
  if( drawAxis) draw_xyz(AXIS_SIZE);
  if( drawNet) draw_net(SPHERE_RADIUS, 18);  
  if( drawGlobe) earth.draw();
  
  points.draw( hs.getPos() );
     
  cam.setMouseControlled(!hs.locked);
  
  cam.beginHUD();
  draw_line();
  cam.endHUD();
}

void keyPressed() {
  if(key == 'a') drawAxis = !drawAxis;
  if(key == 's') drawGlobe = !drawGlobe;
  if(key == 'd') drawNet = !drawNet;
  if(keyCode == 32) running = !running;  
  println("pressed " + key + " " + keyCode); // + " " +keyMac+ " "+  keyCtrl + " "+ keyAlt );
  
  if( keyCode == 37 && speed > 1 ) speed--;
  if( keyCode == 39) speed++;
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
  rotateX(-PI/2);
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
  rotateX(PI/2);
}

void draw_line() {
  stroke(#FFFFFF);
  hs.update();
  hs.display();
}




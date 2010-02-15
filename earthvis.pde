/**
 * Viuslaizing qype reviews via time on the globe
 *
 */

//drawing
import processing.opengl.*; 
import javax.media.opengl.GL; 

//Camera
import peasy.*;

//Data loading
import de.bezier.data.sql.*;

//Point Clustering
import com.hardcorepawn.*;

//GUI Elements
import controlP5.*;

//DB Connection
String DB_USER = "root";
String DB_PASS = "";
String DB_NAME = "earthvis";
String DB_HOST = "127.0.0.1";

/********************************/

float speed = 2;
float speed_step = 0.001;

int SPHERE_RADIUS = 1000;
int AXIS_SIZE = ceil(SPHERE_RADIUS * 1.2);
int LIMIT = 10000; //00;

boolean drawAxis = true;
boolean drawGlobe = true;
boolean drawNet = false;
boolean running = true;

PeasyCam cam;
Ellipsoid earth;
MySQL con;
ClusteredPoints points;
//ControlPanel panel;

ControlP5 controlP5;
ControlGroup l;

HScrollbar hs;

Textfield t1;
Textfield t2;
Textfield t3;
MultiList li;

void setup() {
  size(800, 830, OPENGL); 

  PFont font;
  font = loadFont("Calibri-32.vlw"); 
  textFont(font, 16); 

  con = new MySQL( this, DB_HOST, DB_NAME, DB_USER, DB_PASS );
  if( !con.connect() ) {
    println("couldn't connect to DB: " + DB_HOST + " " + DB_NAME + " " + DB_USER);
    exit();
  }

  points = new ClusteredPoints(this, SPHERE_RADIUS / 100);
  points.setLimit(LIMIT);
  //points.setConditions("domain_id LIKE 'de%'");
  // points.setConditions("login = 'rausauskl'");
  points.load();

  cam = new PeasyCam(this, AXIS_SIZE+350);
  cam.setMinimumDistance(SPHERE_RADIUS+10);
  cam.setMaximumDistance(5*AXIS_SIZE);

  earth = new Ellipsoid(this, 50, 50);
  earth.setTexture("earth.jpg");
  earth.setRadius(SPHERE_RADIUS);
  earth.moveTo(new PVector(0,0,0));
  earth.rotateBy(radians(90), radians(90), 0);

  //panel = new ControlPanel(this, 10, height-30, width-20, 10 );

  hs = new HScrollbar(20, height-75, width-40, 10, 3); //x, y, width, height, loosness

  controlP5 = new ControlP5(this);
  controlP5.setAutoDraw(false);
  controlP5.setColorActive(0xFF666666);
  controlP5.setColorBackground(color(0xFF111111, 200));
  controlP5.setColorForeground(0xFF333333);  
  controlP5.setColorValue(0xFFaaaaaa);

  l = controlP5.addGroup("myGroup",width,30);   
  l.hideBar();
  l.setPosition(0, height-45);
  
  int xOff = 100;
  int s = 220;
  int space = 60;
  int hei = 18;
  controlP5.Textlabel la = controlP5.addTextlabel("Label", "Filter:", 30, 5);
  la.setGroup(l);

  t1 = controlP5.addTextfield("domain_id", xOff, 0, s-space, hei);
  t1.setGroup(l);  
  t1.setAutoClear(false);

  t2 = controlP5.addTextfield("login",     xOff+s, 0, s-space, hei);   
  t2.setGroup(l);  
  t2.setAutoClear(false);
  
  t3 = controlP5.addTextfield("language",xOff+s*2,0, s-space, hei);
  t3.setGroup(l);    
  t3.setAutoClear(false);
  
/*
  li = controlP5.addMultiList("myList",0,10,100,12);
  li.setGroup(l);      
  // create a multiListButton which we will use to
  // add new buttons to the multilist
  li.add("Any",1);
  li.add("DE",2);
  li.add("EN",3);
  li.add("FR",4);
  li.add("PT",5);
  li.add("ES",6);
  li.add("PL",7);
  
  // add items to a sublist of button "level1"
  //b.add("",11).setLabel("All");
//  b.add("de",12).setLabel("de");
  */
  
  println("init done");

  global_reset();
  global_stop();
}

//#################################################

void draw() {  
  rotateX(-PI/2);
  rotateX(-PI/4);

  hs.update();

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
  hs.draw();
  noStroke();
  fill(0xFF333333, 190);
  rect(0, height-60, width, 60);
  controlP5.draw();
  cam.endHUD();
}

void keyPressed() {
  if(t1.isFocus() || t2.isFocus() || t3.isFocus()) return;

  if(key == 'a') drawAxis = !drawAxis;
  if(key == 's') drawGlobe = !drawGlobe;
  if(key == 'd') drawNet = !drawNet;
  if(keyCode == 32) running = !running;  
  //println("pressed " + key + " " + keyCode); // + " " +keyMac+ " "+  keyCtrl + " "+ keyAlt );

  if( keyCode == 37 && speed > 1 ) speed--;
  if( keyCode == 39) speed++;
}

//#################################################################

void draw_xyz(float nsize) {
  //X - Red
  stroke(0xFFff0000);
  line(-nsize,0,nsize,0);

  //Y - Blue
  stroke(0xFF0000ff);  
  line(0,-nsize,0,nsize);

  //Y - Green
  rotateX(-PI/2.0);
  stroke(0xFF00ff00);
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


/* ########################################################### */

public void global_reset() {  
  if(hs != null) hs.setPos(0);   
  if(points != null && points.maxDate != null && hs != null) hs.maxDate = points.maxDate;
  if(points != null && points.maxDate != null && hs != null) hs.minDate = points.minDate;
}

public void global_start() {
  running = true;
}

public void global_stop() {
  running = false;
}


  void	controlEvent(ControlEvent theEvent) {
    String condition = "1=1";
    if(t1.getText().length() > 0) condition += " AND domain_id LIKE '"+t1.getText()+"%'";
    if(t2.getText().length() > 0) condition += " AND login = '"+t2.getText()+"'";
    if(t3.getText().length() > 0) condition += " AND language = '"+t3.getText()+"'"; 
    points.setConditions(condition);
    points.reload(); // = true;
    global_reset();
    global_stop();
  }  



class Review {
  int stars;
  String date;

  float lat;
  float lng;

  float x;
  float y;
  float z;

  color c;

  Review(int _stars, String _date, float _lat, float _lng) {
    this.stars = _stars;
    this.date = _date;
    this.lat = _lat;      
    this.lng = _lng;
    _lat = radians(-lat);
    _lng = radians(lng-90);
    this.x = SPHERE_RADIUS * cos(_lng) * cos(_lat);
    this.y = SPHERE_RADIUS * sin(_lng) * cos(_lat);
    this.z = SPHERE_RADIUS * sin(_lat);    
    this.c = get_color(_stars);
  }

 
  void draw() {
    stroke(this.c); 
    rotateX(PI/2);  
    translate(this.x, -this.y, -this.z);
    point(0,0);
    translate(-this.x, this.y, this.z);
    rotateX(-PI/2);  
  }

  color get_color(int s) {
      if( s == 1 ) return #FF0000;
      if( s == 2 ) return #DD1111;
      if( s == 3 ) return #FFFF00;
      if( s == 4 ) return #99FF00;
      if( s == 5 ) return #00FF00;
      return #0000FF;
  }

  String to_s() {
    return "Review: "+ this.stars + " " + this.date + " " + this.lat + " " +  this.lng;
  }

}


ArrayList review_find(int anz) {
  ArrayList reviews = new ArrayList();
  String query = "SELECT DISTINCT(place_id), x,y,z, lat, lng, date, stars FROM locations ORDER BY date LIMIT " + anz; 

  println(query);

  con.query( query );
  println("done");
  while( con.next() )  {
    reviews.add( new Review( con.getInt("stars"), con.getString("date"), con.getFloat("lat"), con.getFloat("lng") ) );
  } 
  return reviews;
}


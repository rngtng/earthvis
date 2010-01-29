
class Review {
  int stars;
  String date;

  float lat;
  float lng;

  float x;
  float y;
  float z;

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
  }

  String to_s() {
    return "Review: "+ this.stars + " " + this.date + " " + this.lat + " " +  this.lng;
  }

}


ArrayList review_find(int anz) {
  ArrayList reviews = new ArrayList();
  String query = "SELECT DISTINCT(place_id), x,y,z, lat, lng, date, stars FROM locations ORDER BY date LIMIT " + anz; 

  println(query);

  con2.query( query );
  println("done");
  while( con2.next() )  {
  //  t.addPoint(con2.getInt("x"), con2.getInt("y"), con2.getInt("z"), random(1), random(1), random(1), 1);
    reviews.add( new Review( con2.getInt("stars"), con2.getString("date"), con2.getFloat("lat"), con2.getFloat("lng") ) );
  } 
  return reviews;
}    



class Locator {
  float lat;
  float lng;

  color c;

  Locator(float _lat, float _lng, color _c) {
    this.lat = _lat;      
    this.lng = _lng;
    this.c = _c;
  }

  String to_s() {
    return "Locator: " + this.lat + " " +  this.lng;
  }
}


Locator locator_find(String domain_id, color c) {
  String query = "SELECT locators.latitude AS lat, locators.longitude AS lng FROM locators WHERE domain_id = '" + domain_id + "'"; 

  con.query( query );
  con.next();
  Locator l = new Locator(con.getFloat("lat"), con.getFloat("lng"), c);
  println( l.to_s());
  return l; 
}

 /*
  locators = new ArrayList();
  locators.add(locator_find("de600-hamburg", #FF0000));
  locators.add(locator_find("de300-berlin", #FF0000));
  locators.add(locator_find("de212", #FF0000));
 */





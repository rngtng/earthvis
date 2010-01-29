
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
    lat = radians(-lat);
    lng = radians(lng-90);
    this.x = SPHERE_RADIUS * cos(lng) * cos(lat);
    this.y = SPHERE_RADIUS * sin(lng) * cos(lat);
    this.z = SPHERE_RADIUS * sin(lat);    
  }

  String to_s() {
    return "Review: "+ this.stars + " " + this.date + " " + this.lat + " " +  this.lng;
  }

}


ArrayList review_find(int anz) {
  ArrayList reviews = new ArrayList();
  String query = "SELECT DISTINCT(reviews.place_id), reviews.stars AS stars, reviews.updated_at AS date, places.latitude AS lat, longitude AS lng " +
    "FROM reviews JOIN places ON reviews.place_id = places.id " +
    "WHERE places.latitude IS NOT NULL ORDER BY reviews.updated_at LIMIT " + anz; 

  println(query);

  con.query( query );
  println("done");
  while( con.next() )  {
    reviews.add( new Review( con.getInt("stars"), con.getString("date"), con.getFloat("lat"), con.getFloat("lng") ) );
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





import de.bezier.data.sql.*;

de.bezier.data.sql.SQLite db;
MySQL con;


String DB_USER = "root";
String DB_PASS = "";
String DB_NAME = "earthvis";
String DB_HOST = "127.0.0.1";


/* 
 Create table locations ( 
 id INTEGER PRIMARY KEY ASC, lat FLOAT, lng FLOAT, x FLOAT, y FLOAT, z FLOAT, `date` DATE, 
 place_id INTEGER, stars INTEGER, domain_id VARCHAR(50), language VARCHAR(10), 
 login VARCHAR(50) 
 )
 */

/*
String DB_USER = "qype_staging";
 String DB_PASS = "c7c4ea917fb1c61a5c96b23cb3d7d3dc";
 String DB_NAME = "qype_staging";
 String DB_HOST = "seraph.qype.com";
 */

void setup()
{
  size( 10, 10 );

  con = new MySQL( this, DB_HOST, DB_NAME, DB_USER, DB_PASS );
  if( !con.connect() ) {
    println("couldn't connect to DB: " + DB_HOST + " " + DB_NAME + " " + DB_USER);
    exit();
  }

  db = new de.bezier.data.sql.SQLite( this, "../data.rdb" );  // open database file
  if ( !db.connect() )
  {
    println("couldn't connect to Local DB");
    exit();      
  }

  //  do_import();
   do_export();

  noLoop();
}

void draw() {

}


void do_export() {
  con.execute( "TRUNCATE locations" );
  
  String query;

  int num = 5000;

  for(int offset = 0; offset <250; offset++) {
    query = "SELECT * from locations LIMIT "+num+" OFFSET " + num*offset;

    db.query( query );
    println("fetched "+num+", " + num*offset);

    while( db.next() )  {
      float lat = db.getFloat("lat");      
      float lng = db.getFloat("lng");
      float x = db.getFloat("x");
      float y = db.getFloat("y");
      float z = db.getFloat("z");

      String query2 = "INSERT INTO locations "
        + "(id,lat,lng,x,y,z,date,place_id,stars,domain_id,language,login) "
        + "values (" 
        + db.getInt("id")+", "+lat+", "+lng+", "+x+", "+y+", "+z+", '"+db.getString("date")+"', "
        + db.getInt("place_id")+", "+db.getInt("stars")+", '"+db.getString("domain_id")+"', '"+db.getString("language")+"', "
        + "'"+db.getString("login")+"')";
      
      try {
      con.execute( query2 );
      }
      catch( Exception e) {
        println(query2);
      }
    }
  }

  println("imported");
}

void do_import() {
  db.execute( "DELETE FROM locations" );

  String query;

  int num = 5000;

  for(int offset = 0; offset <250; offset++) {
    /* get data from main server */
    query = "SELECT reviews.id, reviews.stars, reviews.created_at AS date, reviews.language, "
      + "place_id, places.domain_id, places.longitude AS lng, places.latitude AS lat, places.name,  "
      + "users.login "
      + "FROM reviews JOIN places ON reviews.place_id = places.id JOIN users ON reviews.user_id = users.id LIMIT "+num+" OFFSET " + num*offset;

    con.query( query );
    println("fetched "+num+", " + num*offset);

    while( con.next() )  {
      //reviews.add( new Review( con.getInt("stars"), con.getString("date"), con.getFloat("lat"), con.getFloat("lng") ) );
      float lat = con.getFloat("lat");      
      float lng = con.getFloat("lng");
      float latr = radians(-lat);
      float lngr = radians(lng-90);
      float x = 100 * cos(lngr) * cos(latr);
      float y = 100 * sin(lngr) * cos(latr);
      float z = 100 * sin(latr);

      String query2 = "INSERT INTO locations "
        + "(id,lat,lng,x,y,z,date,place_id,stars,domain_id,language,login) "
        + "values (" 
        + con.getInt("id")+", "+lat+", "+lng+", "+x+", "+y+", "+z+", '"+con.getString("date")+"', "
        + con.getInt("place_id")+", "+con.getInt("stars")+", '"+con.getString("domain_id")+"', '"+con.getString("language")+"', "
        + "'"+con.getString("login")+"')";

      db.execute( query2 );
    }
  }

  println("imported");
}



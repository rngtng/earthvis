

class ClusteredPoints extends Thread {
  PApplet app;

  String db_conditions;
  int db_limit;

  ArrayList points = null;

  int minDate = 0;
  int maxDate = 0;

  float size;

  boolean loaded;

  ClusteredPoints(PApplet _app, float _size) {
    this.app = _app;
    this.size = _size;

    this.db_conditions = "";
    this.db_limit = 0;

    this.loaded = false;
  }

  void load() {
    if( !this.loaded ) {
      ((Thread) this).start();	           
    }
  }

  void run() { 
    String query = "SELECT place_id, x, y, z, DAY(date) AS day, date + 0 AS date, stars FROM locations";    
    if( this.db_conditions != "" ) query += " WHERE " + this.db_conditions; 
    query += " ORDER BY date";
    if( this.db_limit > 0 ) query += " LIMIT " + this.db_limit; 
    println(query);

    con.query( query );
    println("database done");

    this.points = new ArrayList();
    int old_day = 0;    
    SuperPoint p = null;

    while( con.next() )  {
      int day = con.getInt("day");
      
      this.maxDate = con.getInt("date");
      if(this.minDate == 0) this.minDate = this.maxDate;
      
      if( day != old_day ) {
        if(p != null) this.points.add(p);
        p = new SuperPoint(this.app);
        old_day = day;
      }
      color c = get_color(con.getInt("stars"));
      p.addPoint(con.getFloat("x") * this.size, con.getFloat("y") * this.size, con.getFloat("z") * this.size, red(c), green(c), blue(c), 100 );
    }
    if(p != null) this.points.add(p);
    println("point load done");
    this.loaded = true;
  }

  public void setLimit(int _limit ) {
    this.db_limit = _limit;
  }

  public void setConditions(String _conditions) {
    this.db_conditions = _conditions;
  }

  public void draw( float percentage ) {
    if( points == null) return;
    int anz = ceil(percentage * points.size()); 

    Iterator itr = points.iterator();
    while(itr.hasNext()) {
      if( anz < 1 ) return;
      SuperPoint r = (SuperPoint) itr.next();
      r.draw(1);
      anz--;
    } 
  }

  private color get_color(int stars) {
    if( stars == 1 ) return #FF0000;
    if( stars == 2 ) return #DD1111;
    if( stars == 3 ) return #FFFF00;
    if( stars == 4 ) return #99FF00;
    return ( stars == 5 ) ? #00FF00 : #0000FF;
  }

}

















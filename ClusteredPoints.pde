

class ClusteredPoints extends Thread {
  PApplet app;

  public int entries;
  public Vector points = null;
  public java.sql.Date minDate = null;
  public java.sql.Date maxDate = null;

  private String db_conditions;
  private int db_limit;
  
  int[] star_colors = new int[] {#FFFFFF, #FF0033, #ff6699, #eafcff, #b2f0ff, #00CCFF};
  
  float size;

  boolean running = false;
  boolean loaded = false;

  ClusteredPoints(PApplet _app, float _size) {
    this.points = new Vector();
    this.app = _app;
    this.size = _size;

    this.db_conditions = "";
    this.db_limit = 0;
  }

  public void load() {
    this.loaded = false;
    if( !this.running ) ((Thread) this).start();
  }

  public void draw( float percentage ) {
    if( points == null) return;
    int anz = ceil(percentage * points.size()); 

    int psize = points.size();
    if(psize > anz) psize = anz;
    
    for(int point_at = 0; point_at < anz; point_at++) {
      ((SuperPoint) points.get(point_at)).draw(1);   
    }    
  }  

  void run() { 
    this.running = true;
    while(running) { //more or less endless loop
      if(this.loaded) continue;
      this.loaded = loadData();
    }
  }

  private boolean loadData() {
    this.minDate = null;
    this.maxDate = null;
    this.entries = 0;
    
    this.points.clear();
    System.gc(); //force garbage collection

    // String query = "SELECT x, y, z, DAY(date) AS day, date AS udate, stars FROM locations";    //MYSQL
    String query = "SELECT x, y, z, strftime('%d', date) AS day, strftime('%s', date) * 1000 AS udate, stars FROM locations";    //SQLLITE
    if( this.db_conditions != "" ) query += " WHERE " + this.db_conditions; 
    query += " ORDER BY date";
    if( this.db_limit > 0 ) query += " LIMIT " + this.db_limit; 

    println(query);

    con.query(query);
    print("database done - ");

    int previous_day = 0;    
    SuperPoint p = null;

    while(con.next())  {
      this.entries++;
      int day = con.getInt("day");

      this.maxDate = con.getDate("udate");
      if(this.minDate == null) this.minDate = this.maxDate;
   
      //cluster by day
      if( day != previous_day ) {
        if(p != null) this.points.add(p);
        p = new SuperPoint(this.app);        
        previous_day = day;
      }
      color c = star_colors[con.getInt("stars")];
      p.addPoint(con.getFloat("x") * this.size, con.getFloat("y") * this.size, con.getFloat("z") * this.size, red(c), green(c), blue(c), 100 );
    }
    if(p != null) this.points.add(p);
    println("points updated");        
    return true;
  }

  public void setLimit(int _limit ) {
    this.db_limit = _limit;
  }

  public void setConditions(String _conditions) {
    this.db_conditions = _conditions;
  }
}


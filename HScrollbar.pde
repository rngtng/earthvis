class HScrollbar
{
  int swidth, sheight;    // width and height of bar
  int xpos, ypos;         // x and y position of bar
  float spos, newspos;    // x position of slider
  int sposMin, sposMax;   // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  String minDate = "1. Jan 2006";
  String maxDate = "1. Jan 2006";

  HScrollbar (int xp, int yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    if(over()) {
      over = true;
    } 
    else {
      over = false;
    }
    if(mousePressed && over) {
      locked = true;
    }
    if(!mousePressed) {
      locked = false;
    }
    if(locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if(abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  int constrain(int val, int minv, int maxv) {
    return min(max(val, minv), maxv);
  }

  boolean over() {
    if(mouseX > xpos && mouseX < xpos+swidth &&
      mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } 
    else {
      return false;
    }
  }

  void draw() {
    stroke(0xFFFFFFFF);
    fill(255); 
    text(minDate, xpos, ypos-10);
    text(maxDate, xpos+swidth - textWidth(maxDate), ypos-10);
    line(xpos, ypos + sheight/2, xpos + swidth, ypos + sheight/2);
    stroke(180);
    strokeWeight(2);
    if(over || locked) {
      fill(153, 102, 0);
    } 
    else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
    strokeWeight(1);
  }

  void setPos(float v) {
    spos = newspos = (v  * sposMax) + sposMin; 

  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return (spos - sposMin) / sposMax;
  }
}


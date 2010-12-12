 
require 'ruby-processing'

class MySketch < Processing::App
   load_libraries :opengl
   include_package "processing.opengl"
   
   load_library 'PeasyCam'
   import 'peasy'
   
   attr_reader :cam
  
   SPHERE_RADIUS = 200 
   AXIS_SIZE = SPHERE_RADIUS + 20
   
   def setup
     render_mode OPENGL
     background 0
     
     @cam = PeasyCam.new(self, SPHERE_RADIUS * 2)     
   end

   def draw     
     background 0
      smooth
      
       @cam.beginHUD()
       pointLight(51, 102, 126, 600, 600, 600)
      # pointLight 255, 255, 255, 700, 700, 700 
       @cam.endHUD()    
     
     draw_xyz(AXIS_SIZE)
     draw_net(SPHERE_RADIUS, 9)
     #draw_sphere(SPHERE_RADIUS)
   end

   def draw_xyz(nsize)
     #X - Red
     stroke 255, 0, 0
     line(-nsize, 0, nsize, 0)

     #Y - Blue
     stroke 0, 0, 255
     line(0,-nsize,0,nsize)

     #Y - Green
     rotateX -PI / 2.0
     stroke 0, 255, 0
     line 0, -nsize, 0, nsize

     rotateX(PI/2.0)
   end

   def draw_net( nsize, anz)
     noFill()
     anz.times do |z|
       rotateY(PI/anz)
       #vertival
       stroke(90)
       ellipse(0, 0, nsize*2, nsize*2)
       t = nsize / anz * z
       s = 2 * sqrt( sq(nsize) - sq(t) )
       r = PI/2
       #horizontal
       # actually should be by angle NOT height
       stroke 90
       rotateX r
       translate 0, 0, t
       ellipse(0, 0, s, s)    
       translate(0, 0, -t * 2)    
       ellipse(0, 0, s, s)  
       translate(0, 0, t)
       rotateX(-r)
     end
     
     rotateY(-PI)
   end
   
   def draw_sphere(nsize)
      fill(255)
      no_stroke
      sphere(nsize)
    end
    
 end

MySketch.new :title => "EarthVis", :width => 1000, :height => 800
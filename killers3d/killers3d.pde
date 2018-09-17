import java.util.Iterator;
import java.io.FileWriter;
import java.io.IOException;


float dt=.071; //time step
float cell_radius=2.5; 
int num_cells=0; //just to keep track of the current number of cells so that don't go over max
float eta=.03; //viscosity of medium
int max_num_cells=int((700/cell_radius)*(700/cell_radius)*100); //should adjust so that if you packed spheres effeciently into the volume they would just fill up the volume. optimal packing of spheres is .74
Biofilm bugs= new Biofilm(); //biofilm class just holds all the bacteria in a list and allows insertions and deletions, and manages births and deaths
float k=1.9; //spring constant
float growth_rate=5.25; 
float kill_thresh=0; //number of neighbors required before killing
float grid_width=cell_radius;
float grid_height=cell_radius;
float grid_depth=cell_radius;
PVector gravity=new PVector(0,28,0);
int counter=0;
int global_size=700;
Grid grid=new Grid(grid_height,grid_width,grid_depth,global_size);
int growing=1;
int tick=1;


  
  void setup(){
    size(700,700,P3D);
    lights();
    //directionalLight(0,0,1,0,-1,1);
    background(0);
    init();
    sphereDetail(10);
  }
  
  void init(){
      num_cells=0;
      bugs.bacteria.clear();
      for(int i=0;i<max_num_cells/1000;i++){
      bugs.addBacterium(new Bacterium(new PVector(width*random(1),height-height*random(.05),height*random(1)),cell_radius,rand_color(.5),false,false,growth_rate));
      num_cells++;
    }
  }
  
  void initCyl(){
    num_cells=0;
    bugs.bacteria.clear();
    for(int i=0;i<(int)(width/cell_radius);i++){
      for(int j=0;j<(int)(height/cell_radius);j++){
        for(int k=0;k<(int)(width/cell_radius);k++){
          float w=width/cell_radius;
          float h=height/cell_radius;
          float d= height/cell_radius;
          double x0=(w/2);
          double y0=(h/2);
          double r=Math.sqrt(Math.pow(i+1-x0,2)+Math.pow(k+1-y0,2));
          if(r<5){
            bugs.addBacterium(new Bacterium(new PVector((i+.5)*cell_radius,(j+.5)*cell_radius,(k+.5)*cell_radius),cell_radius,new PVector(255,0,0),false,false,growth_rate));
          }
        else{
          bugs.addBacterium(new Bacterium(new PVector((i+.5)*cell_radius,(j+.5)*cell_radius,(k+.5)*cell_radius),cell_radius,new PVector(0,0,255),false,false,growth_rate));
        }
        num_cells++;
      }
     }
    }
  }
      
  void keyPressed(){
    if(key=='i'){
      init();
    }
    if(key=='j'){
      initCyl();
    }
    if(key=='g'){
      growing=1-growing;
    }
    }
  
  void draw(){
    counter++;
    //println("{",str(millis()),", ",str(num_cells),"}");
    println(counter);
    grid.reset(bugs.bacteria);
    
    if(counter%3000==0){
      background(0);
    }
    if(counter%30==0){
      ArrayList<Float> heights=grid.heights();
      try{
      println("Trying to write heights to 'heightsData.txt'");
      FileWriter writer=new FileWriter("heightsData.txt");
      int writer_counter=0;
      String to_write;
      writer.write("{");
      for(float h:heights){
        if(writer_counter%int(global_size/cell_radius)==0&&writer_counter!=0){
          to_write="}, {{"+str(h)+"}";
          writer.write(to_write);
          //writer.write("{"+str(h)+"},");
          }
        else{
          to_write=", {"+str(h)+"}";
          writer.write(to_write);
        }
        writer_counter++;
      }
      writer.write("}");
      writer.flush();
      writer.close();
      println("success");
      println(writer_counter);
      }
      catch(IOException e) {
        println("didn't work :( :(");
        e.printStackTrace();
      }
    }
    for(Bacterium b:bugs.bacteria){
      if(counter%3000==0){
      b.show();
      }
      if(num_cells<max_num_cells&&growing==1){
      b.grow();
      }
      
      ArrayList<Bacterium> neighbors=new ArrayList<Bacterium>();
      int i=(int)(floor(b.r.x/grid_width));
      int j=(int)(floor(b.r.y/grid_height));
      int k=(int)(floor(b.r.z/grid_depth));
      for(int i1=-1;i1<=1;i1++){
        for(int j1=-1;j1<=1;j1++){
          for(int k1=-1;k1<=1;k1++){
            for(Bacterium bob:grid.sites[pb(int(width/grid_width),i+i1)][pb(int(height/grid_height),j+j1)][pb(int(global_size/grid_depth),k+k1)].contains){
              neighbors.add(bob);
              }
            }
          }
        }
      
      b.r.add(movement(b,neighbors,1.2*cell_radius,k).mult(eta*dt));
      
    }
    
    ArrayList<Bacterium> to_divide=new ArrayList<Bacterium>();
    Iterator<Bacterium> iter = bugs.bacteria.iterator();
    while (iter.hasNext()) {
      Bacterium b = iter.next();
      if (b.radius>cell_radius*1.1){
        if(random(1)>.8){
        to_divide.add(b);
        }
      }
    }
    
    ArrayList<Bacterium> to_kill=new ArrayList<Bacterium>();
    Iterator<Bacterium> iter2 = bugs.bacteria.iterator();
    while (iter2.hasNext()) {
      Bacterium b2 = iter2.next();
      if(b2.enemy_count*random(1)>kill_thresh){
        //if(random(1)>.999){
      to_kill.add(b2);
      }
    }
    
    bugs.update(to_divide,to_kill);
    
    }


float pb(int size,float x){ 
  int intpart=(floor(x)+size)%size;
  float floatpart=x-(int)x;
  return floatpart+intpart;
}

PVector movement(Bacterium bug, ArrayList<Bacterium> bacteria, float cut_off, float k){
  PVector f=new PVector(0,0,0);
  bug.enemy_count=0;
  for(Bacterium b:bacteria){
    PVector disp=PVector.sub(b.r,bug.r);
    if(disp.mag()<cell_radius){
      if(disp.mag()!=0){
        f.add((disp.add(disp.mult((bug.radius+b.radius)/disp.mag())).mult(-k)).mult(1));
      }
    }
    if(disp.mag()<cut_off){
      if(b.species_color.x!=bug.species_color.x){
        bug.enemy_count++;
      }
    }
    }
  f.add(gravity);
  return(f);
}
    

PVector rand_color(float p_red){
  if(random(1)>p_red){
    return(new PVector(255,0,0));
  }
  return(new PVector(0,0,255));
  //return(new PVector(random(255),random(255),random(255)));
}

int pb(int size, int x){
  return((x+size)%size);
}
      
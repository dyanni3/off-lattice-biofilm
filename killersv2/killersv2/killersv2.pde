//VISCOSITY SIMS

import java.util.Iterator;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;

float dt=.071;
float cell_radius=10;
int num_cells=0;
float eta=.05;
int max_num_cells=(int)((1200/cell_radius)*(400/cell_radius));
float k=1.9;
float growth_rate=.39;
float kill_thresh=2;
float grid_width=cell_radius;
float grid_height=cell_radius;
PVector gravity=new PVector(0,28,0);
int counter=0;
int global_width=1200;
int global_height=400;
Grid grid=new Grid(grid_height,grid_width);
boolean rheology_running;
int first_run=0;
Bacterium rheology_b=new Bacterium(new PVector(width*random(1),height-height*random(.05),0),cell_radius,new PVector(0,255,0),false,false,growth_rate);
ArrayList<Bacterium> tracers=new ArrayList<Bacterium>();
ArrayList<PVector> tracer_positions=new ArrayList<PVector>();
int writenow=0;
int killing=0;
float apop_thresh=.995;


//initialize objects. Biofilm holds all the bacteria. Grid divides up space to make nearest neighbors search faster
Biofilm bugs= new Biofilm();
int growing=1; //if zero then cells don't grow
int initial_counter=0;
int trails=0; //if one then tracers leave trails so that you can look at the entire trajectory of a tracer


//Common to all processing sketches  
void setup(){
  size(1200,400);
  background(0);
  init();
}       
  
// Initialize sketch  
void init(){
    num_cells=0;
    bugs.bacteria.clear(); // clear all existing cells (in case re-initializing)
    
    //make a bunch of cells,red and blue. To make just one species use rand_color(0) instead of rand_color(x/600).
    for(int i=0;i<max_num_cells-500;i++){
      float x=width*random(1);
      bugs.addBacterium(new Bacterium(new PVector(x,height-height*random(.2),0),cell_radius,rand_color(0),false,false,growth_rate));
      num_cells++;
    }
   
    //make the tracers
    for(int j=0;j<1;j++){
    Bacterium rheology_b=new Bacterium(new PVector(width*random(1),height-height*random(.25),0),cell_radius,new PVector(0,255,0),false,false,growth_rate);
    tracers.add(rheology_b);
    bugs.addBacterium(rheology_b);
    num_cells++;
    }
}
  
// User control of the sketch through keyboard
void keyPressed(){
  
  if(key=='i'){ //standard initialization
    init();
  }
  
  if(key=='t'){ //add trails
    trails=1-trails;
    background(0);
  }
  
  if(key=='g'){ //stop all growth (killing and other behaviors still active)
    growing=1-growing;
  }
  
  if(key=='m'){//microrheology
    rheology_running=true;
    first_run=1;
    write_rms();
  }
  
  if(key=='w'){
    write_rms();
  }

  if(key=='k'){ //turns killing on/off
    killing=1-killing;
  }
}
  
//DRAW FUNCTION, has a lot of stuff going on, but most of it is to do with measuring displacements, fraction to top, etc.
//The main thing you want to look at is the update() function.
void draw(){
  
  //update biofilm and draw bacteria to screen (this function loops continuously)
  println(counter);
  update();
  rheology();
  
  if(counter%100 == 0){
    write_rms();
  } 
  
}
  


void rheology(){ 
  
  if(rheology_running){
    if(first_run==1){
      if(trails==1){
        for(Bacterium b:tracers){
          b.r0=new PVector(b.r.x,b.r.y,b.r.z);
        }
      first_run=2;
      }
      else{
        for(Bacterium b:bugs.bacteria){
          b.r0=new PVector(b.r.x,b.r.y,b.r.z);
        }
        first_run=2;
      }
    }
    if(first_run==2){
      for(Bacterium b:bugs.bacteria){
        b.rf=b.r;
      }
    }
  }
}


//for periodic boundary conditions (toroidal wrapping)
float pb(int size,float x){ 
  int intpart=(floor(x)+size)%size;
  float floatpart=x-(int)x;
  return floatpart+intpart;
}

int pb(int size, int x){
  return((x+size)%size);
}

// Movement response (spring force, viscous drag)
PVector movement(Bacterium bug, ArrayList<Bacterium> bacteria, float cut_off, float k){//takes as input a bug and a list of its neighbors
  PVector f=new PVector(0,0,0); //initialize force on bug to zero
  
  bug.enemy_count=0;//counter for number of enemy neighbors
  for(Bacterium b:bacteria){
    PVector disp=PVector.sub(b.r,bug.r);
    if(abs(height-bug.r.y)<cell_radius){
      f.add(new PVector(0,height-bug.r.y,0));
    }
    if(disp.mag()<1.1*cell_radius){
      f.add(disp.normalize().mult(-1).mult(1));
    }
    disp=PVector.sub(b.r,bug.r);
    if(disp.mag()<cell_radius){
      if(disp.mag()!=0){
        f.add((disp.add(disp.mult((bug.radius+b.radius)/disp.mag())).mult(-k)).mult(1));//add spring force from cells in neighborhood
      }
    }
    if(disp.mag()<cut_off){
      if(b.species_color.x!=bug.species_color.x&&b.species_color.y==0){
        bug.enemy_count++;
      }
    }
    }
  f.add(gravity); //add gravity
  return(f);
}
    
//picks either red or blue (or totally random for previous version)
PVector rand_color(float p_red){
  if(random(1)>p_red){
    return(new PVector(255,0,0));
  }
  return(new PVector(0,0,255));
  //return(new PVector(random(255),random(255),random(255)));
}

void update(){
  counter++;
    
    //tell the grid structure where all the bacteria are O(n)
    grid.reset(bugs.bacteria);
    
    if(trails==0){
    background(0);
    }
    
    for(Bacterium b:bugs.bacteria){
      b.show();//actually draws the bug
      b.clock+=dt;
      if(num_cells<max_num_cells&&growing==1){
        b.grow();//only grow if fewer than max number cells in simulation
      }
      
      //Find the nearest neighbors of each cell
      ArrayList<Bacterium> neighbors=new ArrayList<Bacterium>();
      int i=(int)(floor(b.r.x/grid_width));
      int j=(int)(floor(b.r.y/grid_height));
      for(int i1=-1;i1<=1;i1++){
        for(int j1=-1;j1<=1;j1++){
          for(Bacterium bob: grid.sites[pb(int(width/grid_width),i+i1)][pb(int(height/grid_height),j+j1)].contains){
            neighbors.add(bob);
          }
        }
      }
      
      //this bacterium gets pushed on by neighbors closer than its cell radius to itself (spring force, viscous response)
      b.r.add(movement(b,neighbors,1.2*cell_radius,k).mult(eta*dt));
    }
    
    //figure out which cells are ready to reproduce, looks needlessly complicated because 
    //there's stuff to acount for if reproduction at bottom layer only, or at top only, etc.
    ArrayList<Bacterium> to_divide=new ArrayList<Bacterium>();
    Iterator<Bacterium> iter = bugs.bacteria.iterator();
                      float ymin=height;
                  for(Bacterium b2:bugs.bacteria){
                    if(b2.r.y<ymin){
                      ymin=b2.r.y;
                    }
                  }
    while (iter.hasNext()) {
      Bacterium b = iter.next();
      if (b.radius>1.2*cell_radius){
        if(random(1)>.9){
          if(b.species_color.y==0){ //if not tracer
        to_divide.add(b);
          }
        }
      }
    }
    
    //figure out which bacteria have been stabbed
    ArrayList<Bacterium> to_kill=new ArrayList<Bacterium>();
    Iterator<Bacterium> iter2 = bugs.bacteria.iterator();
    while (iter2.hasNext()) {
      Bacterium b2 = iter2.next();
      if(b2.enemy_count*random(1)>kill_thresh){
        if(b2.species_color.y==0&&killing==1){
      to_kill.add(b2);
        }
      }
      if(random(1)>apop_thresh&&killing==1){
        //println("DEATH EVENT!!!");
        if(b2.species_color.y==0){
        to_kill.add(b2);
        }
      }
    }
    
    //update biofilm (delete stabbed cells and add new daughter cells)
    bugs.update(to_divide,to_kill);
    }
  
void write_rms(){
  //ArrayList<Float> heights=grid.heights();
  int bin_counter=0;
  
  if(trails==1&&rheology_running==true){
    try{
      println("Trying to write displacements to 'dispData.txt'");
      FileWriter writer=new FileWriter("d_data//dispData.txt");
      for(Bacterium b:tracers){
        writer.write(str(PVector.sub(b.rf,b.r0).mag())+", ");
        writer.write('\n');
        writer.write(str(b.clock)+", ");
      }
      writer.flush();
      writer.close();
      println("success");
    }
    catch(IOException e) {
      println("didn't work :( :(");
      e.printStackTrace();
    }
  }
  
  else if(rheology_running==true){      
    try{
      println("Trying to write displacements to 'dispData.txt'");
      FileWriter writer=new FileWriter("dispData"+str(counter)+".txt");
      for(Bacterium b:bugs.bacteria){
        writer.write(str(PVector.sub(b.rf,b.r0).mag())+", ");
        writer.write('\n');
        writer.write(str(b.clock)+", ");
      }
      writer.flush();
      writer.close();
      println("success");
    }
    catch(IOException e) {
      println("didn't work :( :(");
      e.printStackTrace();
    }
  }
}
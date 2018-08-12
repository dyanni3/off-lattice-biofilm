//VISCOSITY SIMS

import java.util.Iterator;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;
boolean one_species=true;

float dt=.071;
float cell_radius=10;
int num_cells=0;
float eta=.05;
int max_num_cells=(int)((1200/cell_radius)*(400/cell_radius));
float k=1.9;
float growth_rate=.05;
float kill_thresh=4;
float grid_width=cell_radius;
float grid_height=cell_radius;
PVector gravity=new PVector(0,28,0);
int counter=0;
int global_width=1200;
int global_height=400;
Grid grid=new Grid(grid_height,grid_width);
boolean rheology_running;
boolean long_rheology_running;
boolean active_zone_rheology_running;
int first_run=0;
Bacterium rheology_b=new Bacterium(new PVector(width*random(1),height-height*random(.05),0),cell_radius,new PVector(0,255,0),false,false,growth_rate);
ArrayList<Bacterium> tracers=new ArrayList<Bacterium>();
Bins active_zones= new Bins();
boolean bottom_only=false;
boolean top_only=false;
boolean vector_plot=false;
ArrayList<Float> frac_to_top= new ArrayList<Float>();
ArrayList<Float> time_to_top=new ArrayList<Float>();
ArrayList<PVector> tracer_positions=new ArrayList<PVector>();
int writenow=0;
int killing=0;
float apop_thresh=.99;
boolean save_snapshots=false;


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
      save_snapshots=false; //if true saves pics every so often
      num_cells=0;
      bugs.bacteria.clear(); // clear all existing cells (in case re-initializing)
      
      //make a bunch of cells,red and blue. To make just one species use rand_color(0) instead of rand_color(x/600).
      for(int i=0;i<max_num_cells-500;i++){
        float x=width*random(1);
        bugs.addBacterium(new Bacterium(new PVector(x,height-height*random(.2),0),cell_radius,rand_color(int(x/600)),false,false,growth_rate));
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
    
    if(key=='a'){ //quantify activity in active zones (distance from killing interface)
      println("Active Zone: ON");
      delay(500);
      active_zone_rheology_running=true;
      long_rheology_running=false;
      rheology_running=false;
      first_run=1;
    }
    
    if(key=='t'){ //add trails
      trails=1-trails;
      background(0);
    }
    
    if(key=='l'){ //long-style MSD
      long_rheology_running=true;
      rheology_running=false;
      first_run=1;
    }
    
    if(key=='g'){ //stop all growth (killing and other behaviors still active)
      growing=1-growing;
    }
    
    if(key=='m'){//microrheology
      rheology_running=true;
      long_rheology_running=false;
      first_run=1;
      //write_rms();
    }
    
    if(key=='w'){
      write_rms();
    }
    
    if(key=='h'){
      write_heights();
    }
    
    if(key=='f'){
      write_frac_to_top();
    }
    
    if(key=='v'){
      write_vector_plot();
    }
    
    if(key=='p'){
      write_pos();
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
  
  // save snapshots if true
  if(counter%400==0 & save_snapshots==true){
    save("test_snapshot_"+str(counter)+".tif");
  }
  
  // make vector plot if true
  if(vector_plot){
    if(int(bugs.bacteria.get(0).clock)%4==0&&writenow==0){
      writenow=1;
      println("writing");
    for(Bacterium tracer:tracers){
      tracer_positions.add(new PVector(tracer.r.x,height-tracer.r.y,0));
    }
    }
    else if(int(bugs.bacteria.get(0).clock)%4!=0){
      writenow=0;
    }
  } 
  
}
  
  
void frac(){ //for fraction to top, ignore.
    println("Time: "+str(bugs.bacteria.get(0).clock));
    time_to_top.add(bugs.bacteria.get(0).clock);
    float ymin=height;
    for(Bacterium b2:bugs.bacteria){
      if(b2.r.y<ymin){
        ymin=b2.r.y;
      }
    }
  int frac_count=0;
  println(height-ymin);
  for(Bacterium tracer:tracers){
    if(tracer.r.y-ymin<.5*(height-ymin)){
      frac_count+=1;
    }
  }
  //println(bugs.bacteria.get(0).rf.sub(bugs.bacteria.get(0).r0).mag()-bugs.bacteria.get(0).r0.mag());
  println(frac_count/500.);
  frac_to_top.add(frac_count/500.);
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
        microrheology(b);
      }
    }
  }
  
  if(long_rheology_running){
    if(first_run==1){
      if(trails==1){
        for(Bacterium b:tracers){
          b.r0=new PVector(b.r.x,b.r.y,b.r.z);
          b.clock=0;
        }
      first_run=2;
      }
      else{
        for(Bacterium b:bugs.bacteria){
          b.r0=new PVector(b.r.x,b.r.y,b.r.z);
          b.clock=0;
        }
        first_run=2;
      }
    }
    if(first_run==2&&trails==0){
      for(Bacterium b:bugs.bacteria){
        b.long_rheology_list.add(PVector.sub(b.r,b.r0));
        b.times.add(b.clock);
      }
    }
    else if(first_run==2&&trails==1){
      for(Bacterium b:tracers){
        b.long_rheology_list.add(PVector.sub(b.r,b.r0));
        b.times.add(b.clock);
      }
    }
  }
  
  
  if(active_zone_rheology_running){
    if(first_run==1){
      for(Bacterium b:bugs.bacteria){
        b.r0=new PVector(b.r.x,b.r.y,b.r.z);
        int bin_opt=int(abs((b.r.x-600)/50));
        //if (bin_opt==0){
        //  b.bin=0;
        //}
        //else if(bin_opt==1){
        //  b.bin=1;
        //}
        //else{
        //  b.bin=2;
        //}
        b.bin=bin_opt;
        b.clock=0;
      }
      first_run=2;
    }
    else{
      for(Bacterium b:bugs.bacteria){
        //check which bin it's in
        int current_bin_opt=int(abs(b.r.x-600)/50);
        int current_bin;
        //if (current_bin_opt==0 || current_bin_opt==1){
        //  current_bin=current_bin_opt;
        //}
        //else{
        //  current_bin=2;
        //}
        current_bin=current_bin_opt;
        //if it switched bins then reset its r0 and clock and bin
        if (current_bin!=b.bin){
          b.r0=new PVector(b.r.x,b.r.y,b.r.z);
          b.clock=0;
          b.bin=current_bin;
        }
        else{
          //otherwise it has been in the same bin since last time, calculate its MSD and time and add to this bin's xt list
          float x= PVector.sub(b.r,b.r0).mag();
          float t=b.clock;
          active_zones.bins[b.bin].add_xt(x,t);
        }
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

void microrheology(Bacterium b){
  b.rf=b.r;
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
    
    //figure out which cells are ready to reproduce, looks needlessly complicated because there's stuff to acount for if reproduction at bottom layer only, or at top only, etc.
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
          if(b.species_color.y==0){
            if(bottom_only){
                  float h_div=(height-ymin);
                  float x_div=(height-b.r.y);
                  float fact_div=(1-(float)Math.pow(x_div/h_div,.25));
                  if(random(1)<fact_div){
              //if(b.r.y>.95*height){
                to_divide.add(b);
              }
              else{
                continue;
              }
            }
            if(top_only){
              //float ymin=height;
              for(Bacterium b2:bugs.bacteria){
                if(b2.r.y<ymin){
                  ymin=b2.r.y;
                }
              }
              if(b.r.y-ymin<6*cell_radius){
                to_divide.add(b);
              }
              else{
                continue;
              }
            }
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
      if(random(1)>apop_thresh&&killing==1&&one_species==false){
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
      
      if(active_zone_rheology_running==true){
        try{
          println("Trying to write active zones to 'dispData.txt'");
          FileWriter fw= new FileWriter("dispData.txt");
          BufferedWriter writer=new BufferedWriter(fw);
           bin_counter=0;
          for(Bin this_bin:active_zones.bins){
            writer.write("Bin number " + str(bin_counter));
            writer.newLine();
            bin_counter++;
            for(Float[] vals:this_bin.xt){
              writer.write(str(vals[0])+","+str(vals[1]));
              writer.newLine();
            }
          }
          writer.flush();
          writer.close();
          println("success");
        }
        catch(IOException e){
          delay(500);
          println("Failed...");
          delay(500);
          e.printStackTrace();
        }
      }
      
      if(trails==1&&rheology_running==true){
        try{
          println("Trying to write displacements to 'dispData.txt'");
          FileWriter writer=new FileWriter("dispData.txt");
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
      
    else if(long_rheology_running==true){
      if (trails==0){
        try{
          println("Trying to write displacements to 'dispData.txt'");
          FileWriter fw=new FileWriter("dispData.txt");
          BufferedWriter writer=new BufferedWriter(fw);
          for(int i=0;i<1000;i++){
            Bacterium b=bugs.bacteria.get(i);
            for(PVector displacement:b.long_rheology_list){
              writer.write(str(displacement.mag())+", ");
            }
            writer.newLine();
            for(Float time:b.times){
              writer.write(str(time)+", ");
            }
            writer.newLine();
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
      else if(long_rheology_running==true&& trails==1){
        try{
          println("Trying to write displacements to 'dispData.txt'");
          FileWriter fw=new FileWriter("dispData.txt");
          BufferedWriter writer=new BufferedWriter(fw);
          for(Bacterium b:tracers){
            for(PVector displacement:b.long_rheology_list){
              writer.write(str(displacement.mag())+", ");
            }
            writer.newLine();
            for(Float time:b.times){
              writer.write(str(time)+", ");
            }
            writer.newLine();
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
      
}

void write_heights(){
      ArrayList<Float> heights=grid.heights();
      try{
      println("Trying to write heights to 'heightsData.txt'");
      FileWriter writer=new FileWriter("heightsData.txt");
      for(float h:heights){
        writer.write(str(h)+", ");
        writer.write("\n");
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

void write_frac_to_top(){
  try{
    println("Trying to write frac to top to 'frac_to_top.txt'");
    FileWriter fw= new FileWriter("frac_to_top.txt");
    BufferedWriter writer= new BufferedWriter(fw);
    for (int i=0; i<frac_to_top.size();i++){
      writer.write(str(time_to_top.get(i))+", "+str(frac_to_top.get(i)));
      writer.newLine();
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
  
void write_vector_plot(){
  try{
    println("Trying to write frac to top to 'vector_plot.txt'");
    FileWriter fw= new FileWriter("vector_plot.txt");
    BufferedWriter writer= new BufferedWriter(fw);
    //writer.write(str(tracer_positions.size()));
    //writer.newLine();
    //writer.write("ttt");
    //writer.newLine();
    //for (int i=0; i<int(tracer_positions.size()/500);i++){
    //  for(int j=0;j<500;j++){
    //    writer.write(str(i+j)+", "+str(tracer_positions.get(i+j).x)+", "+str(tracer_positions.get(i+j).y));
    //    writer.newLine();
    //}
    //writer.write("ttt");
    //writer.newLine();
    //}
    for(PVector pos: tracer_positions){
      writer.write(pos.x+", "+pos.y);
      writer.newLine();
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
  
void write_pos(){
  try{
    println("Trying to write frac to top to 'snapshot.txt'");
    FileWriter fw= new FileWriter("snapshot.txt");
    BufferedWriter writer= new BufferedWriter(fw);
    for(Bacterium b: bugs.bacteria){
      
      //if red, write '1, x, y'
      if(b.species_color.x==255){
        writer.write(1+", "+b.r.x+", "+str(height-b.r.y));
        writer.newLine();
      }
      
      //if blue, write '2, x, y'
      else if(b.species_color.z==255){
        writer.write(2+", "+b.r.x+", "+str(height-b.r.y));
        writer.newLine();
      }
      
      else{
        writer.write(3+", "+b.r.x+", "+str(height-b.r.y));
        writer.newLine();
      }
      
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
    
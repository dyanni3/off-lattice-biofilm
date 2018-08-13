class Bacterium {
  PVector r;
  ArrayList<Bacterium> neighborhood;
  PVector next_position;
  float radius;
  PVector species_color;
  boolean divided;
  boolean killed;
  float clock;
  float growth_rate;
  int enemy_count;
  PVector r0;
  PVector rf;
  ArrayList<PVector> long_rheology_list;
  ArrayList<Float> times;
  int bin;
  
  Bacterium( PVector r, float radius, PVector species_color, boolean divided, boolean killed,float growth_rate){
    this.r=r;
    this.neighborhood=neighborhood;
    this.next_position=next_position;
    this.radius=radius;
    this.species_color=species_color;
    this.divided=divided;
    this.killed=killed;
    this.clock=0;
    this.growth_rate=growth_rate;
    this.r0= new PVector(r.x,r.y,r.z);
    this.rf=new PVector(0,0,0);
    this.long_rheology_list=new ArrayList<PVector>();
    this.times=new ArrayList<Float>();
    this.bin=99;
  }
  
  void show(){ //bug displays itself (also sets position to toroidal wrapping conditions)
    r.x=Math.min(width,r.x);
    r.x=Math.max(0,r.x);
    r.y=Math.min(height,r.y);
    r.y=Math.max(0,r.y);
    //r.x=pb(global_width,r.x);
    //r.y=pb(global_height,r.y);
    //r.z=Math.min(height/2,r.z);
    //r.z=Math.max(width/4,r.z);
    if(species_color.x==255){
      if(trails==0){
      fill(species_color.x/1.5,species_color.y, species_color.z+20,50);
    
    stroke(60);
    pushMatrix();
    translate(r.x, r.y);
    //sphere(14);
    ellipse(0,0,radius,radius);
    popMatrix();
      }
  }
  else if(species_color.z==255){
    if(trails==0){
    fill(species_color.x,species_color.y, species_color.z,60);
    stroke(60);
    pushMatrix();
    translate(r.x, r.y);
    //sphere(14);
    ellipse(0,0,radius,radius);
    popMatrix();  
    }
  }
  else{
    if(trails==0){
    fill(species_color.x,species_color.y, species_color.z);
    noStroke();
    pushMatrix();
    translate(r.x, r.y);
    //sphere(14);
    ellipse(0,0,radius,radius);
    popMatrix();  
    }
    else{
    fill(species_color.x,species_color.y, species_color.z);
    noStroke();
    pushMatrix();
    translate(r.x, r.y);
    //sphere(14);
    ellipse(0,0,radius/4,radius/4);
    popMatrix();  
    }  
  }
  }
  
  
  void grow(){
    if(species_color.y==0){
    radius=radius+(2*(float)Math.PI*dt*growth_rate)/radius;
    }
  }
  
}
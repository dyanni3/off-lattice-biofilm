class Site {
  
  //PVector origin;
  //float grid_height;
  //float grid_width;
  ArrayList <Bacterium> contains;
  
  //Site(PVector origin, float grid_height,float grid_width){
  Site(){
    contains=new ArrayList<Bacterium>();
    //this.origin=origin;
    //this.grid_height=grid_height;
    //this.grid_width=grid_width;
  }
  
  void addBacterium(Bacterium b) {
    contains.add(b);
  }
  void removeBacterium(Bacterium b){
    contains.remove(b);
  }
  void clearBacteria(){
    contains.clear();
  }
}

class Grid{
  
  Site[][] sites;
  float grid_h;
  float grid_w;
  
  Grid(float temp_grid_height ,float temp_grid_width){
    grid_h=temp_grid_height;
    grid_w=temp_grid_width;
    
    
    //len=(int)((width*height)/(grid_height*grid_width)+1);
    //len=100060;
    sites=new Site[int(global_width/grid_w)][int(global_height/grid_h)];
    for(int h1=0;h1<int(global_height/grid_h);h1++){
      for(int w1=0;w1<int(global_width/grid_w);w1++){
      sites[w1][h1]=new Site();
      }
    }
  }
  
  void reset(ArrayList<Bacterium> bacteria){
    for(int h=0;h<int(global_height/grid_height);h++){
      for(int w=0;w<int(global_width/grid_width);w++){
      sites[w][h].clearBacteria();
    }
    }
    for(Bacterium b:bacteria){
      int i=pb(int(global_width/grid_width),int(b.r.x/grid_width));
      int j=pb(int(global_height/grid_height),int(b.r.y/grid_height));
      sites[i][j].addBacterium(b);
      }
    }
  
  void wave(){
    for(int h=0;h<int(global_height/grid_height);h++){
      for(int w=0;w<int(global_width/grid_width);w++){
      for(Bacterium b: sites[w][h].contains){
        b.r.y=b.r.y-5;
      }
    }
  }
  }
  
  ArrayList heights(){
    float y_max=0;
    ArrayList h_list=new ArrayList();
    for(int x=0;x<int(global_width/grid_w);x++){
      y_max=0;
      for(int y=int(global_height/grid_h)-1;y>=0;y--){
        for(Bacterium bob:sites[x][y].contains){
          if(global_height-bob.r.y>y_max){
            y_max=global_height-bob.r.y;
            }
          }
        }
        h_list.add(y_max);
      }
    return(h_list);
    }          
}

    
  


    
  
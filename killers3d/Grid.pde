class Site {
  ArrayList <Bacterium> contains;

  Site(){
    contains=new ArrayList<Bacterium>();
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
  
  Site[][][] sites;
  float grid_h;
  float grid_w;
  float grid_d;
  int global_size;
  
  Grid(float temp_grid_height ,float temp_grid_width,float temp_grid_depth,int global_size){
    grid_h=temp_grid_height;
    grid_w=temp_grid_width;
    grid_d=temp_grid_depth;
    this.global_size=global_size;
    
    sites=new Site[int(global_size/grid_w)][int(global_size/grid_h)][int(global_size/grid_d)];
    //sites=new Site[58][58][58];
    int d1=0;
    for(int w1=0;w1<int(global_size/grid_w);w1++){
      for(int h1=0;h1<int(global_size/grid_h);h1++){
        for(d1=0;d1<int(global_size/grid_d);d1++){
          sites[w1][h1][d1]=new Site();
        }
      }
    }
  }
  
  void reset(ArrayList<Bacterium> bacteria){
    for(int h=0;h<int(global_size/grid_height);h++){
      for(int w=0;w<int(global_size/grid_width);w++){
        for(int d=0;d<int(global_size/grid_depth);d++){
          sites[w][h][d].clearBacteria();
        }
      }
    }
    for(Bacterium b: bacteria){
      int i=pb(int(global_size/grid_w),int(b.r.x/grid_w));
      int j=pb(int(global_size/grid_h),int(b.r.y/grid_h));
      int k=pb(int(global_size/grid_h),int(b.r.y/grid_d));
      sites[i][j][k].addBacterium(b);  
    }
  }
  
    ArrayList heights(){
    float y_max=0;
    ArrayList h_list=new ArrayList();
    for(int x=0;x<int(global_size/grid_w);x++){
      for(int z=0;z<int(global_size/grid_d);z++){
      y_max=0;
      for(int y=int(global_size/grid_h)-1;y>=0;y--){
        for(Bacterium bob:sites[x][y][z].contains){
          if(global_size-bob.r.y>y_max){
            y_max=global_size-bob.r.y;
            }
          }
        }
        h_list.add(y_max);
      }
    }
    return(h_list);
    } 
}


    
  

class Biofilm {
  ArrayList<Bacterium> bacteria;
  Biofilm(){
    bacteria = new ArrayList<Bacterium>(); 
  }

  void addBacterium(Bacterium b) {
    bacteria.add(b);
  }
  void removeBacterium(Bacterium b){
    bacteria.remove(b);
  }
  
  void update(ArrayList<Bacterium> to_divide,ArrayList<Bacterium> to_kill){
    for(Bacterium b3:to_divide){
      b3.radius=cell_radius;
      if(num_cells<max_num_cells){
      Bacterium daughter=new Bacterium(PVector.add(b3.r,PVector.random2D().mult(b3.radius)),cell_radius,b3.species_color,false,false,b3.growth_rate);
      bugs.addBacterium(daughter);
      num_cells++;
      }
    }
    for(Bacterium b:to_kill){
      bugs.removeBacterium(b);
      num_cells--;
    }
  }
}
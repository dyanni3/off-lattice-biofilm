class Bin{
  
  ArrayList<Float[]> xt;
  
  Bin(){
    xt=new ArrayList<Float[]>();
  }
  
  void add_xt(float x, float t){
    Float[] to_add=new Float[2];
    to_add[0]=x;
    to_add[1]=t;
    xt.add(to_add);
  }
  
}

class Bins{
  
  Bin[] bins;
  
  Bins(){
    bins=new Bin[13];
    for(int i=0;i<13;i++){
      bins[i]=new Bin();
    }
  }
}
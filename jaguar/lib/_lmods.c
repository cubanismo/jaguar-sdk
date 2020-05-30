long _lmods(long z,long n)
{
    unsigned long t=1,uz,un;int s=0;
    if(!n) return(0);
    if(z>=0) uz=z; else {uz=-z;s=1;}
    if(n>=0) un=n; else un=-n;
    while(un<=0xffffffff/2&&un<=uz/2){
        un*=2;t++;
    }
    while(t){
        if(uz>=un){ uz-=un;}
        t--;
        un/=2;
    }
    if(s) return(-(long)uz); else return((long)uz);
}

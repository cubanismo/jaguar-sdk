unsigned long _ldivu(unsigned long z,unsigned long n)
{
    unsigned long q=0,t=1;
    if(!n) return(0);
    while(n<=0xffffffff/2&&n<=z/2){
        t*=2;
        n*=2;
    }
    while(t){
        if(z>=n){ q+=t; z-=n;}
        t/=2;
        n/=2;
    }
    return(q);
}

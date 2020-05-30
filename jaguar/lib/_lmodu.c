unsigned long _lmodu(unsigned long z,unsigned long n)
{
    unsigned long t=1;
    if(!n) return(0);
    while(n<=0xffffffff/2&&n<=z/2){
        n*=2;t++;
    }
    while(t){
        if(z>=n){ z-=n;}
        t--;
        n/=2;
    }
    return(z);
}

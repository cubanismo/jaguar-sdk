#include <exec/devices.h>
#include <devices/timer.h>
#include <clib/exec_protos.h>

#include <stdlib.h>

extern struct __exitfuncs *__firstexit;

static struct timerequest tr;
struct Device *TimerBase;

static long freq;

struct pd{
    struct pd *next;
    struct EClockVal total,laststart;
    char *name;
    unsigned long count;
} *first;

void _closeprof(void)
/*  schliesst alles und gibt Ergebnis aus   */
{
    struct pd *p,*m;
    printf("Freq=%ld\n",freq);
    p=first;
    while(p){
        if(p!=first)
            printf("%s: calls=%lu,total=%lu,%lu\n",p->name,p->count,p->total.ev_hi,p->total.ev_lo);
        m=p;
        p=p->next;
        FreeMem(m,sizeof(struct pd));
    }
    if(TimerBase) CloseDevice((struct IORequest *)&tr);
}

int _initprof(void)
/*  oeffnet timer.device etc.   */
{
    struct __exitfuncs *p,*new;
/*    puts("initprof start");*/
    if(OpenDevice(TIMERNAME,UNIT_ECLOCK,(struct IORequest *)&tr,0)) return(1);
    TimerBase=tr.tr_node.io_Device;
    first=AllocMem(sizeof(struct pd),0);
    if(!first) return(1);
    first->next=0;
    first->name=0;
    freq=ReadEClock(&first->total);
    first->total.ev_hi=first->total.ev_lo=0;
    /*  _closeprof als letzte atexit-Funktion   */
    if(!(new=malloc(sizeof(struct __exitfuncs)))) return(1);
    new->next=0;
    new->func=_closeprof;
    p=__firstexit;
    if(!p){
        __firstexit=new;
    }else{
        while(p->next) p=p->next;
        p->next=new;
    }
/*    puts("initprof end");*/
    return(0);
}
void _startprof(char *name)
/*  wird beim Eintritt in eine Funktion gerufen */
{
    struct pd *p=first;
/*    puts("startprof start");*/
    if(!p) {if(_initprof()) return; else p=first;}
    while(p->name!=name&&p->next!=0) p=p->next;
    if(p->name!=name){
        p->next=AllocMem(sizeof(struct pd),0);
        if(!p->next) return;
        p=p->next;
        p->name=name;
        p->next=0;
        p->count=0;
        p->total.ev_hi=p->total.ev_lo=0;
    }
    p->count++;
    ReadEClock(&p->laststart);
/*    puts("startprof start");*/
}
void _endprof(char *name)
/*  wird am Ende einer Funktion gerufen */
{
    struct pd *p=first;struct EClockVal t;
/*    puts("endprof start");*/
    if(!p) return;
    ReadEClock(&t);
    while(p->name!=name&&p->next!=0) p=p->next;
    if(p->name!=name) {/*puts("no match");*/return;}
    p->total.ev_hi+=t.ev_hi-p->laststart.ev_hi;
    p->total.ev_lo+=t.ev_lo-p->laststart.ev_lo;
    if(t.ev_lo<=p->laststart.ev_lo) p->total.ev_hi++;
/*    puts("endprof end");*/
}



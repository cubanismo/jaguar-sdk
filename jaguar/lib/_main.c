/*  _main()-Routine fuer vbcc-Amiga-Version */
/*  initialisiert stdin, stdout, stderr etc.    */

/*  MATH_IEEE definieren, wenn die MathIeee-Libraries benutzt werden sollen */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <libraries/dos.h>
#include <proto/dos.h>

FILE *stdin,*stdout,*stderr,*_firstfile=0,*_lastfile=0;

extern int main(int, char **);
extern BPTR _stdin,_stdout,_stderr;

#ifdef MATH_IEEE
#include <proto/exec.h>
struct Library *MathIeeeDoubBasBase,*MathIeeeDoubTransBase,*MathIeeeSingBasBase;
#endif

void _main(int argc, char **argv)
{
    stdin=(FILE *)malloc(sizeof(FILE));
    stdout=(FILE *)malloc(sizeof(FILE));
    stderr=(FILE *)malloc(sizeof(FILE));
    if(!stdin||!stdout||!stderr) exit(EXIT_FAILURE);
    stdin->filehandle=(char*)_stdin;
    stdin->flags=_READABLE;if(IsInteractive(_stdin)) stdin->flags|=_UNBUF;
    stdout->filehandle=(char*)_stdout;
    stdout->flags=_WRITEABLE;if(IsInteractive(_stdout)) stdout->flags|=_LINEBUF;
    stderr->filehandle=(char*)_stderr;
    stderr->flags=_WRITEABLE;if(IsInteractive(_stderr)) stderr->flags|=_UNBUF;
    stdin->pointer=stdout->pointer=stderr->pointer=0;
    stdin->base=stdout->base=stderr->base=0;
    stdin->count=stdout->count=stderr->count=0;
    stdin->bufsize=stdout->bufsize=stderr->bufsize=0;
    stdin->prev=0;stdin->next=stdout;
    stdout->prev=stdin;stdout->next=stderr;
    stderr->prev=stdout;stderr->next=0;
    _firstfile=stdin;_lastfile=stderr;
#ifdef MATH_IEEE
    if(!(MathIeeeSingBasBase=OpenLibrary("mathieeesingbas.library",37L)))
        exit(EXIT_FAILURE);
    if(!(MathIeeeDoubBasBase=OpenLibrary("mathieeedoubbas.library",37L)))
        exit(EXIT_FAILURE);
    if(!(MathIeeeDoubTransBase=OpenLibrary("mathieeedoubtrans.library",37L)))
        exit(EXIT_FAILURE);
#endif
    exit(main(argc,argv));
/*    main(argc,argv);*/
}

/*  Wie sieht das genau aus? Das ist eine Asm-Routine   */
extern void _exit();

struct __exitfuncs *__firstexit;

/*  exit()-Routine fuer vbcc-Amiga-Version  */
void exit(int returncode)
{
    struct __exitfuncs *p=__firstexit;
    /*  atexit-Routinen starten */
    while(p){p->func();p=p->next;}
#ifdef MATH_IEEE
    if(MathIeeeDoubTransBase) CloseLibrary(MathIeeeDoubTransBase);
    if(MathIeeeDoubBasBase) CloseLibrary(MathIeeeDoubBasBase);
    if(MathIeeeSingBasBase) CloseLibrary(MathIeeeSingBasBase);
#endif
    /*  alle offenen Files schliessen   */
    while(_firstfile&&!fclose(_firstfile));
    /*  allen Speicher freigeben        */
    _freemem();
    _exit(returncode);
}

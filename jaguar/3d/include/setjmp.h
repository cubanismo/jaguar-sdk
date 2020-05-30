#ifndef _SETJMP_H
#define _SETJMP_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif


typedef char *jmp_buf[13]; /* retaddr, 12 regs */


__EXTERN int	setjmp	__PROTO((jmp_buf));
__EXTERN void	longjmp	__PROTO((jmp_buf, int));


#ifdef __cplusplus
}
#endif

#endif /* _SETJMP_H */

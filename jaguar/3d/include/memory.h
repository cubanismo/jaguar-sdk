#ifndef _MEMORY_H
#define _MEMORY_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _SIZE_T
#define _SIZE_T __SIZE_TYPEDEF__
typedef _SIZE_T size_t;
#endif

#ifndef alloca
#  ifndef __GNUC__
#    ifndef __cplusplus
        __EXTERN void *alloca __PROTO((size_t));
#    else
        __EXTERN void *alloca __PROTO((long unsigned int));
#    endif
#  else
#    define alloca(X) __builtin_alloca(X)
#  endif
#endif

__EXTERN void *malloc __PROTO((size_t n));
__EXTERN void free __PROTO((void *param));
__EXTERN void *realloc __PROTO((void *_r, size_t n));
__EXTERN void *calloc __PROTO((size_t n, size_t sz));
__EXTERN void _malloczero __PROTO((int yes));
__EXTERN void _mallocChunkSize __PROTO((size_t siz));

__EXTERN void *_malloc __PROTO((unsigned long n));
__EXTERN void *_realloc __PROTO((void *_r, unsigned long n));
__EXTERN void *_calloc __PROTO((unsigned long n, unsigned long sz));

__EXTERN void *sbrk __PROTO((size_t));
__EXTERN void *lsbrk __PROTO((long));
__EXTERN void *_sbrk __PROTO((long));

#ifndef alloca
#  ifndef __cplusplus
    __EXTERN void *alloca __PROTO((size_t));
#  else
     __EXTERN void *alloca __PROTO((long unsigned int));
#  endif
#endif

#ifdef __SOZOBON__
__EXTERN void *lmalloc __PROTO((long));
__EXTERN void *lrealloc __PROTO((void *, long));
__EXTERN void *lcalloc __PROTO((long, long));
#endif

#ifdef __cplusplus
}
#endif
  
#endif /* _MEMORY_H */

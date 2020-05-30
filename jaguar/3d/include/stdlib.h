/*
 * stdlib.h
 *	ansi draft sec 4.10
 */
#ifndef _STDLIB_H
#define _STDLIB_H

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

#ifndef _WCHAR_T
#define _WCHAR_T __WCHAR_TYPEDEF__
typedef _WCHAR_T wchar_t;
#endif

#ifdef __MSHORT__
#define	RAND_MAX	(0x7FFF)	/* maximum value from rand() */
#else
#define	RAND_MAX	(0x7FFFFFFFL)	/* maximum value from rand() */
#endif

#define MB_CUR_MAX	1		/* max. length of multibyte character
					   in current locale */

#ifndef EXIT_FAILURE
#define EXIT_FAILURE	(1)
#define EXIT_SUCCESS	(0)
#endif

typedef struct {
    int		quot;	/* quotient	*/
    int		rem;	/* remainder 	*/
} div_t;

typedef struct {
    long	quot;	/* quotient	*/
    long	rem;	/* remainder 	*/
} ldiv_t;

__EXTERN double atof __PROTO((const char *s));
__EXTERN int atoi __PROTO((const char *str));
__EXTERN long atol __PROTO((const char *str));
__EXTERN long int strtol __PROTO((const char *nptr, char **endptr, int base));
__EXTERN unsigned long int strtoul __PROTO((const char *nptr, char **endptr, int base));
__EXTERN double strtod __PROTO((const char *s, char **endptr)); /* sigh! */

__EXTERN void srand __PROTO((unsigned int seed));
__EXTERN int rand __PROTO((void));

__EXTERN void *malloc __PROTO((size_t n));
__EXTERN void free __PROTO((void *param));
__EXTERN void *realloc __PROTO((void *_r, size_t n));
__EXTERN void *calloc __PROTO((size_t n, size_t sz));
#ifndef __STRICT_ANSI__

#  ifndef alloca
#    ifndef __GNUC__
#      ifndef __cplusplus
          __EXTERN void *alloca __PROTO((size_t));
#      else
          __EXTERN void *alloca __PROTO((long unsigned int));
#      endif /* __cplusplus */
#    else
#      define alloca(X) __builtin_alloca(X)
#    endif /* __GNUC__ */
#  endif /* alloca */

#  ifdef atarist
     __EXTERN void _malloczero __PROTO((int yes));
     __EXTERN void _mallocChunkSize __PROTO((size_t siz));
#  endif

#endif /* __STRICT_ANSI__ */

__EXTERN __EXITING abort __PROTO((void));
#ifndef __cplusplus
  /* bug in g++ 1.39.0 -- cant digest proto */
__EXTERN int atexit __PROTO((void (*)(void)));
#endif
__EXTERN __EXITING exit __PROTO((int status));

__EXTERN char *getenv __PROTO((const char *tag));
__EXTERN int system __PROTO((const char *s));

__EXTERN void *bsearch __PROTO((const void *key, const void *base, size_t num, size_t size, int (*cmp )(const void *, const void *)));
__EXTERN void qsort __PROTO((void *base, size_t total_elems, size_t size, int (*cmp )(const void *, const void *)));

__EXTERN int abs __PROTO((int x));
__EXTERN long labs __PROTO((long x));

__EXTERN div_t div __PROTO((int num, int denom));
__EXTERN ldiv_t ldiv __PROTO((long num, long denom));

#ifdef __cplusplus
}
#endif

#endif /* _STDLIB_H */

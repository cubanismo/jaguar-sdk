/*
 * String functions.
 */
#ifndef _STRING_H
#define _STRING_H

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

#ifndef NULL
#define NULL __NULL
#endif

__EXTERN void *memcpy __PROTO((void *dst, const void *src, size_t size));
__EXTERN void *memmove __PROTO((void *dst, const void *src, size_t size));
__EXTERN int memcmp __PROTO((const void *s1, const void *s2, size_t size));
__EXTERN void *memchr __PROTO((const void *s, int ucharwanted, size_t size));
__EXTERN void *memset __PROTO((void *s, int ucharfill, size_t size));

__EXTERN char *strcpy __PROTO((char *dst, const char *src));
__EXTERN char *strncpy __PROTO((char *dst, const char *src, size_t n));
__EXTERN char *strcat __PROTO((char *dst, const char *src));
__EXTERN char *strncat __PROTO((char *dst, const char *src, size_t n));
__EXTERN int strcmp __PROTO((const char *scan1, const char *scan2));
__EXTERN int strncmp __PROTO((const char *scan1, const char *scan2, size_t n));
__EXTERN int strcoll __PROTO((const char *scan1, const char *scan2));
__EXTERN size_t	strxfrm __PROTO((char *to, const char *from, size_t maxsize));
__EXTERN char *strchr __PROTO((const char *s, int charwanted));
__EXTERN size_t strcspn __PROTO((const char *s, const char *reject));
__EXTERN char *strpbrk __PROTO((const char *s, const char *breakat));
__EXTERN char *strrchr __PROTO((const char *s, int charwanted));
__EXTERN size_t strspn __PROTO((const char *s, const char *accept));
__EXTERN char *strstr __PROTO((const char *s, const char *wanted));
__EXTERN char *strtok __PROTO((char *s, const char *delim));
__EXTERN size_t strlen __PROTO((const char *scan));
__EXTERN char *strerror __PROTO((int errnum));

#if !defined(__STRICT_ANSI__) && !defined(_POSIX_SOURCE)
/* 
 * from henry spencers string lib
 *  these dont appear in ansi draft sec 4.11
 */
__EXTERN void *memccpy __PROTO((void *dst, const void *src, int ucharstop, size_t size));
__EXTERN char *strlwr __PROTO((char *string));
__EXTERN char *strupr __PROTO((char *string));
__EXTERN char *strrev __PROTO((char *string));
__EXTERN char *strdup __PROTO((const char *s));

/*
 * V7 and BSD compatibility.
 */
__EXTERN char *index __PROTO((const char *s, int charwanted));
__EXTERN char *rindex __PROTO((const char *s, int charwanted));
__EXTERN void bcopy __PROTO((const void *src, void *dst, size_t length));
__EXTERN int bcmp __PROTO((const void *src, const void *dst, size_t n));
__EXTERN void bzero __PROTO((void *b, size_t n));

__EXTERN int stricmp __PROTO(( const char *, const char * ));
__EXTERN int strnicmp __PROTO(( const char *, const char *, size_t ));
__EXTERN int strcmpi __PROTO(( const char *, const char * ));
__EXTERN int strncmpi __PROTO(( const char *, const char *, size_t ));

#endif /* __STRICT_ANSI__ */

/* some macro versions of functions. these are faster, but less
   forgiving of NULLs and similar nasties. to use the library functions,
   just #undef the appropriate things.
*/

#ifdef __GNUC_INLINE__
# ifndef __cplusplus

static __inline__
char *
__strcat(char *dst, const char *src)
{
	register char *_dscan;

	for (_dscan = dst; *_dscan; _dscan++) ;
	while ((*_dscan++ = *src++)) ;
	return dst;
}

static __inline__ 
char *
__strcpy(char *dst, const char *src)
{
	register char *_dscan = dst;
	while ((*_dscan++ = *src++)) ;
	return dst;
}

static __inline__
size_t
__strlen(const char *scan)
{
	register const char *_start = scan+1;
	while (*scan++) ;
	return (size_t)((long)scan - (long)_start);
}

#define strcat 	__strcat
#define strcpy 	__strcpy
#define strlen 	__strlen

# endif /* !__cplusplus */
#endif /* __GNUC_INLINE__ */

#ifdef __cplusplus
}
#endif

#endif /* _STRING_H */

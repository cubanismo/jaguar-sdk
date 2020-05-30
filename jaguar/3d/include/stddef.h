/*
 * STDDEF.H	standard definitions
 *	ansi draft sec 4.14
 */

#ifndef _STDDEF_H
#define _STDDEF_H

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

#ifndef _PTRDIFF_T
#define _PTRDIFF_T __PTRDIFF_TYPEDEF__
typedef _PTRDIFF_T ptrdiff_t;
#endif

#ifndef _WCHAR_T
#define _WCHAR_T __WCHAR_TYPEDEF__
typedef _WCHAR_T wchar_t;
#endif

/* A null pointer constant.  */
#ifndef NULL
#define NULL __NULL
#endif

/* Offset of member MEMBER in a struct of type TYPE.  */
#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)

#if !defined(EXIT_FAILURE) && !defined(_POSIX_SOURCE)
#define	EXIT_FAILURE	(1)		/* failure return value for exit() */
#define	EXIT_SUCCESS	(0)		/* success return value for exit() */
#endif

#ifdef __cplusplus
}
#endif

#endif /* _STDDEF_H */

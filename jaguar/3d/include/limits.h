/*
 *	LIMITS.H
 *	see ansi draft sec 4.1.3 and 2.2.4.2
 *	Some of this stuff is bogus, since the Jaguar
 *	doesn't have a file system...
 */

#ifndef	_LIMITS_H
#define	_LIMITS_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#define CHAR_BIT 8

#define SCHAR_MAX 127
#define SCHAR_MIN (-128)
#define UCHAR_MAX 255

#ifdef __CHAR_UNSIGNED__
#define CHAR_MAX UCHAR_MAX
#define CHAR_MIN 0
#else
#define CHAR_MAX SCHAR_MAX
#define CHAR_MIN SCHAR_MIN
#endif

#define SHRT_MAX 32767
#define SHRT_MIN (-32768)
#define LONG_MAX 2147483647L
#define LONG_MIN (-LONG_MAX-1) /* this fixes the float cast problem ! */
#define USHRT_MAX 65535U
#define ULONG_MAX 4294967295UL

#ifdef __MSHORT__ /* 16 bit ints */
#define INT_MAX SHRT_MAX
#define INT_MIN SHRT_MIN
#define UINT_MAX USHRT_MAX

#else /* 32 bit ints */

#define INT_MAX 2147483647
#define INT_MIN (-INT_MAX-1) /* this fixes the float cast problem ! */
#define UINT_MAX 4294967295U

#endif /* __MSHORT__ */

#if defined(__GNUC__) && !defined(__STRICT_ANSI__) && !defined(_POSIX_SOURCE)
/* Minimum and maximum values a `signed long long int' can hold.  */
#define LONG_LONG_MAX 9223372036854775807LL
#define LONG_LONG_MIN (-LONG_LONG_MAX-1)

/* Maximum value an `unsigned long long int' can hold.  (Minimum is 0).  */
#define ULONG_LONG_MAX 18446744073709551615ULL

#endif /* __GNUC__ && !__STRICT_ANSI__ && !_POSIX_SOURCE*/
  
#define MB_LEN_MAX	1	/* max. number of bytes in a multibyte character */

/*
 * POSIX-specific stuff; see 1003.1 sect. 2.9
 *
 * Note that the library is *not* POSIX compliant; hence
 * the illegally small values for some constants (e.g. _POSIX_LINK_MAX)
 */

#define _POSIX_ARG_MAX		4096
#define _POSIX_CHILD_MAX	6
#define _POSIX_LINK_MAX		8
#define _POSIX_MAX_CANON	64	/* <- NON-CONFORMING */
#define _POSIX_MAX_INPUT	64	/* <- NON-CONFORMING */
#define _POSIX_NAME_MAX		14
#define _POSIX_NGROUPS_MAX	512	/* <- arbitrary */
#define _POSIX_OPEN_MAX		16
#define _POSIX_PATH_MAX		128	/* <- NON-CONFORMING */
#define _POSIX_PIPE_BUF		512
#define _POSIX_STREAM_MAX	_NFILE

#endif /* _LIMITS_H */

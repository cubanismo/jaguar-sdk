#ifndef _TYPES_H
#define _TYPES_H

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

#ifndef _TIME_T
#define _TIME_T long
typedef _TIME_T time_t;
#endif

#ifndef _POSIX_SOURCE
typedef unsigned char	u_char;
typedef unsigned short	u_short;
typedef unsigned int 	u_int;
typedef unsigned long	u_long;
typedef void *		caddr_t;
#endif /* _POSIX_SOURCE */

#ifdef __cplusplus
}
#endif

#endif /* _TYPES_H */

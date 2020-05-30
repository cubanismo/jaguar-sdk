/*
 *	ctype.h		Character classification and conversion
 */

#ifndef _CTYPE_H
#define _CTYPE_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

extern	unsigned char	*_ctype;

#define	_CTc	0x01		/* control character */
#define	_CTd	0x02		/* numeric digit */
#define	_CTu	0x04		/* upper case */
#define	_CTl	0x08		/* lower case */
#define	_CTs	0x10		/* whitespace */
#define	_CTp	0x20		/* punctuation */
#define	_CTx	0x40		/* hexadecimal */

#define	isalnum(c)	(_ctype[(unsigned char)(c)]&(_CTu|_CTl|_CTd))
#define	isalpha(c)	(_ctype[(unsigned char)(c)]&(_CTu|_CTl))
#ifndef _POSIX_SOURCE
#define	isascii(c)	!((c)&~0x7F)
#endif /* _POSIX_SOURCE */
#define	iscntrl(c)	(_ctype[(unsigned char)(c)]&_CTc)
#define	isdigit(c)	(_ctype[(unsigned char)(c)]&_CTd)
#define	isgraph(c)	(!(_ctype[(unsigned char)(c)]&(_CTc|_CTs)) && (_ctype[(unsigned char)(c)]))
#define	islower(c)	(_ctype[(unsigned char)(c)]&_CTl)
#define isprint(c)      (!(_ctype[(unsigned char)(c)]&_CTc) && (_ctype[(unsigned char)(c)]))
#define	ispunct(c)	(_ctype[(unsigned char)(c)]&_CTp)
#define	isspace(c)	(_ctype[(unsigned char)(c)]&_CTs)
#define	isupper(c)	(_ctype[(unsigned char)(c)]&_CTu)
#define	isxdigit(c)	(_ctype[(unsigned char)(c)]&_CTx)

#define	_toupper(c)	((c)^0x20)
#define	_tolower(c)	((c)^0x20)

#ifndef _POSIX_SOURCE
#define iswhite(c)	isspace(c)
#define	toascii(c)	((c)&0x7F)

#ifdef __GNUC__
/* use safe versions */

#if 0 /* do not define, these are routines in ctype.c as they should be */
#define	toupper(c) \
    ({typeof(c) _c = (c);     \
	    islower(_c) ? (_c^0x20) : _c; })
#define	tolower(c)  \
    ({typeof(c) _c = (c);     \
	    isupper(_c) ? (_c^0x20) : _c; })
#endif /* 0 */

#define toint(c)    \
    ({typeof(c) _c = (c);     \
	    (_c <= '9') ? (_c - '0') : (toupper(_c) - 'A'); })
#define isodigit(c) \
    ({typeof(c) _c = (c);      \
	    (_c >='0') && (_c<='7'); })
#define iscymf(c)   \
    ({typeof(c) _c = (c);      \
	    isalpha(_c) || (_c == '_'); })
#define iscym(c)    \
    ({typeof(c) _c = (c);      \
	    isalnum(_c) || (_c == '_'); })

#else /* you know what */

#if 0 /* see above */
#define	toupper(c)	(islower(c) ? (c)^0x20 : (c))
#define	tolower(c)	(isupper(c) ? (c)^0x20 : (c))
#endif

#define toint(c)	( (c) <= '9' ? (c) - '0' : toupper(c) - 'A' )
#define isodigit(c)	( (c)>='0' && (c)<='7' )
#define iscymf(c)	(isalpha(c) || ((c) == '_') )
#define iscym(c)	(isalnum(c) || ((c) == '_') )

#endif /* __GNUC__ */
#endif /* _POSIX_SOURCE */

__EXTERN int	toupper	__PROTO((int));
__EXTERN int 	tolower	__PROTO((int));

#ifdef __cplusplus
}
#endif

#endif /* _CTYPE_H */

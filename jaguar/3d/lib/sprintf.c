#include <stdarg.h>

#define SPRINTF_MAX 255

int vsprintf(char *buf, const char *fmt, va_list args);
int sprintf(char *, const char *, ...);

#define isdigit(c) ((c)>='0' && (c)<='9')

/*
 * sprintf implements a very crude sprintf() function that provides only
 * a limited subset of formats; also, it will output at most
 * SPRINTF_MAX characters
 */

static int
PUTC(char *p, int c, int *cnt, int width) {
	int put = 1;

	if (*cnt <= 0) return 0;
	*p++ = c;
	*cnt -= 1;
	while (*cnt > 0 && --width > 0) {
		*p++ = ' ';
		*cnt -= 1;
		put++;
	}
	return put;
}

static int
PUTS(char *p, const char *s, int *cnt, int width) {
	int put = 0;

	if (s == 0) s = "(null)";

	while (*cnt > 0 && *s) {
		*p++ = *s++;
		put++;
		*cnt -= 1;
		width--;
	}
	while (width-- > 0 && *cnt > 0) {
		*p++ = ' ';
		put++;
		*cnt -= 1;
	}
	return put;
}

static char obuf[32];

static int
PUTL(char *p, unsigned long u, int base, int *cnt, int width, int fill_char)
{
	int put = 0;
	char *t;

	t = obuf;

	do {
		*t++ = "0123456789ABCDEF"[u % base];
		u /= base;
		width--;
	} while (u > 0);

	while (width-- > 0 && *cnt > 0) {
		*p++ = fill_char;
		put++;
		*cnt -= 1;
	}
	while (*cnt > 0 && t != obuf) {
		*p++ = *--t;
		put++;
		*cnt -= 1;
	}
	return put;
}

int
vsprintf(char *buf, const char *fmt, va_list args)
{
	char *p = buf, c, fill_char;
	char *s_arg;
	int i_arg;
	long l_arg;
	int cnt;
	int width, long_flag;

	cnt = SPRINTF_MAX - 1;
	while( (c = *fmt++) != 0 ) {
		if (c != '%') {
			p += PUTC(p, c, &cnt, 1);
			continue;
		}
		c = *fmt++;
		width = 0;
		long_flag = 0;
		fill_char = ' ';
		if (c == '0') fill_char = '0';
		while (c && isdigit(c)) {
			width = 10*width + (c-'0');
			c = *fmt++;
		}
		if (c == 'l' || c == 'L') {
			long_flag = 1;
			c = *fmt++;
		}
		if (!c) break;

		switch (c) {
		case '%':
			p += PUTC(p, c, &cnt, width);
			break;
		case 'c':
			i_arg = va_arg(args, int);
			p += PUTC(p, i_arg, &cnt, width);
			break;
		case 's':
			s_arg = va_arg(args, char *);
			p += PUTS(p, s_arg, &cnt, width);
			break;
		case 'd':
			if (long_flag) {
				l_arg = va_arg(args, long);
			} else {
				l_arg = va_arg(args, int);
			}
			if (l_arg < 0) {
				p += PUTC(p, '-', &cnt, 1);
				width--;
				l_arg = -l_arg;
			}
			p += PUTL(p, l_arg, 10, &cnt, width, fill_char);
			break;
		case 'o':
			if (long_flag) {
				l_arg = va_arg(args, long);
			} else {
				l_arg = va_arg(args, unsigned int);
			}
			p += PUTL(p, l_arg, 8, &cnt, width, fill_char);
			break;
		case 'x':
			if (long_flag) {
				l_arg = va_arg(args, long);
			} else {
				l_arg = va_arg(args, unsigned int);
			}
			p += PUTL(p, l_arg, 16, &cnt, width, fill_char);
			break;
		case 'u':
			if (long_flag) {
				l_arg = va_arg(args, long);
			} else {
				l_arg = va_arg(args, unsigned int);
			}
			p += PUTL(p, l_arg, 10, &cnt, width, fill_char);
			break;

		}
	}
	*p = 0;
	return (int)(p - buf);
}

int
sprintf(char *buf, const char *fmt, ...)
{
	va_list args;
	int foo;

	va_start(args, fmt);
	foo = vsprintf(buf, fmt, args);	
	va_end(args);
	return foo;
}


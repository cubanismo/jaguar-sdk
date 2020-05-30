/* As suggested by Harbison & Steele */

#include <stddef.h>
#include <stdlib.h>

__EXTERN long strtol __PROTO((const char *, char **, int));

int atoi(str)
const char *str;
{
	return (int) strtol(str, (char **)0, 10);
}

long atol(str)
const char *str;
{
	return strtol(str, (char **)0, 10);
}

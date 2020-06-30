/* from Henry Spencer's stringlib */
/* check for NULL string added by ERS */

#include <string.h>
#undef strcpy

/*
 * strcpy - copy string src to dst
 */
char *				/* dst */
strcpy(dst, src)
char *dst;
const char *src;
{
	register char *dscan = dst;
	register const char *sscan = src;

	if (!sscan) sscan = "";
	while ((*dscan++ = *sscan++) != '\0')
		continue;
	return(dst);
}

/* from Henry Spencer's stringlib */
#include <string.h>

/*
 * strrchr - find last occurrence of a character in a string
 */

char *				/* found char, or NULL if none */
strrchr(s, charwanted)
const char *s;
register int charwanted;
{
	register char c;
	register const char *place;

	place = NULL;
	while ((c = *s++) != 0)
		if (c == (char) charwanted)
			place = s - 1;
	if ((char) charwanted == '\0')
		return((char *)--s);
	return (char *)place;
}

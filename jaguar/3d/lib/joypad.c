#include "joypad.h"

JOYSTREAM *JOY1, *JOY2;

/* static joypad streams */
static JOYSTREAM _J1, _J2;

void
_init_JOY(void)
{
	JOY1 = &_J1;
	JOY2 = &_J2;
	JOY1->curval = JOY1->lastval = 0;
	JOY2->curval = JOY2->lastval = 0;
	JOY1->addr = 0;
	JOY2->addr = 0;
}

unsigned long
JOYget(JOYSTREAM *J)
{
	extern unsigned long _PAD1();
	extern unsigned long _PAD2();

	J->lastval = J->curval;
	if (J == &_J1) {
		J->curval = _PAD1();
	} else {
		J->curval = _PAD2();
	}
	return J->curval;
}

unsigned long
JOYedge(JOYSTREAM *J)
{
	return (J->lastval ^ J->curval) & J->curval;
}


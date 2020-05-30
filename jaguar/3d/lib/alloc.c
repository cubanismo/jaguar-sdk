/*
 *	alloc.c
 */

#include "alloc.h"
#include <stdlib.h>

unsigned long	memavlbl;	 /* 2 MB of RAM */

unsigned char	*memptr;
static unsigned short memflag;

HEADER	*morecore(unsigned long);

static HEADER	base;		/* empty list to get started */

static HEADER	*allocp;	/* last allocated block */

extern char BSS_E[];		/* end of bss */

void *malloc(nbytes)		/* general purpose storage allocator */
unsigned long nbytes;
{
	HEADER *morecore();
	register HEADER *p, *q;
	register unsigned long nunits;

	nbytes += 8;		/* always allow a little slop */

	nunits = 1L + (nbytes + sizeof(HEADER) - 1L) / sizeof(HEADER);
	if ((q = allocp) == NULL) {  /* no free list yet */
		base.s.ptr = allocp = q = &base;
		base.s.size = 0L;
	}
	for (p = q->s.ptr; ; q = p, p = p->s.ptr) {
		if (p->s.size >= nunits) {	/* big enough ? */
			if (p->s.size == nunits) /* exactly */
				q->s.ptr = p->s.ptr;
			else {			/* allocate tail end */
				p->s.size -= nunits;
				p += p->s.size;
				p->s.size = nunits;
			}
			allocp = q;
			p->magic = MAGIC;
			return ((void*)(p + 1));
		}
		if (p == allocp) {	/* wrapped around free list */
			if ((p = morecore(nunits)) == NULL) {
				return NULL; /* none left */
			}
		}
	}
}


HEADER *morecore(nu)	/* ask system for memory */
unsigned long nu;
{
	char	*sbrk();
	register char *cp;
	register HEADER *up;
	register long rnu;

	rnu = NALLOC * ((nu + NALLOC - 1L) / NALLOC);
	cp = sbrk(rnu * sizeof(HEADER));
	if (cp == NULL)
		return NULL;	/* no space at all */
	up = (HEADER *) cp;
	up->s.size = rnu;
	up->magic = MAGIC;
	free((char*)(up + 1L));
	return (allocp);
}

void
free(ap)	/* put block ap in free list */
void *ap;
{
	register HEADER	*p, *q;

	if (!ap) return;

	p = (HEADER *)ap - 1;

	if (p->magic != MAGIC) {
		abort();
	}

	p->magic = 0;

	for (q = allocp; !(p > q && p < q->s.ptr); q = q->s.ptr)
		if (q >= q->s.ptr && (p > q || p < q->s.ptr))
			break;

	if (p + p->s.size == q->s.ptr) { /* join to upper nbr */
		p->s.size += q->s.ptr->s.size;
		p->s.ptr = q->s.ptr->s.ptr;
	} else
		p->s.ptr = q->s.ptr;
	if (q + q->s.size == p) {	/* join to loer nbr */
		q->s.size += p->s.size;
		q->s.ptr = p->s.ptr;
	} else
		q->s.ptr = p;
	allocp = q;
}



char *sbrk(nb)
unsigned long nb;
{
	char *rptr;
	long endphrase;

	if (!memflag) {
		endphrase = (long)BSS_E;
		memptr = (char *)( (endphrase + 7L) & ~7L );
		memflag = 1;
	}
	
	if ((unsigned long)(memptr + nb) > memavlbl)
		return NULL;
	else {
		rptr = memptr;
		memptr += nb;

		return rptr;
	}	
	
}

void
_init_alloc()
{
	memflag = 0;
	memptr = NULL;
	allocp = NULL;
	base.s.size = 0L;
	base.magic = 0L;
	memavlbl = 2048L * 1024L - 4096;	/* reserve the last page for debugging */
}


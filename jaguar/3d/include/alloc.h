/*
 *	alloc.h
 */

#ifndef NULL
#define NULL 0L
#endif

#ifndef MEMCON2
#define MEMCON2	0xf00002
#endif

#define NALLOC	256L	/* # units to allocate at once */

typedef long ALIGN;

union header {	/* free block header */
	struct {
		union header	*ptr;	/* next free block */
		unsigned long	size;	/* size of the free blokc */
	} s;
	ALIGN	magic;
};

typedef union header HEADER;

#define MAGIC 0x0a110cL

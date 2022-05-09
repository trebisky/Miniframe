/*
 *	machdep.c
 */

/* Copy bytes within kernel */
bcopy(from, to, count)
register char *from, *to;
unsigned count;
{
	while ( count-- )
	    *to++ = *from++;
}

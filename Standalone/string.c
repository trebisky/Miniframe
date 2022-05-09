/*
 * Standalone system cannot be complied with libc on vax as libc may
 * (does) use non-emulated instructions on Micro-VAXen and standalone
 * code does not provide emulation for those instructions.
 *
 * These versions taken from 4.2 when they were still in 'C' - rjk
 */
#define	NULL	0

char *
index(sp, c)
register char *sp, c;
{
	do {
		if (*sp == c)
			return(sp);
	} while (*sp++);
	return(NULL);
}

char *
strcat(s1, s2)
register char *s1, *s2;
{
	register char *os1;

	os1 = s1;
	while (*s1++)
		;
	--s1;
	while (*s1++ = *s2++)
		;
	return(os1);
}
/* @(#)strcmp.c	4.1 (Berkeley) 12/21/80 */

strcmp(s1, s2)
register char *s1, *s2;
{

	while (*s1 == *s2++)
		if (*s1++=='\0')
			return(0);
	return(*s1 - *--s2);
}
/* @(#)strcpy.c	4.1 (Berkeley) 10/5/82 */

char *
strcpy(s1, s2)
register char *s1, *s2;
{
	register char *os1;

	os1 = s1;
	while (*s1++ = *s2++)
		;
	return(os1);
}
/* @(#)strlen.c	4.1 (Berkeley) 12/21/80 */

strlen(s)
register char *s;
{
	register n;

	n = 0;
	while (*s++)
		n++;
	return(n);
}

char *
strncpy(s1, s2, n)
register char *s1, *s2;
{
	register i;
	register char *os1;

	os1 = s1;
	for (i = 0; i < n; i++)
		if ((*s1++ = *s2++) == '\0') {
			while (++i < n)
				*s1++ = '\0';
			return(os1);
		}
	return(os1);
}

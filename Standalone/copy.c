/*
 * Copyright (c) 1982, 1986 Regents of the University of California.
 * All rights reserved.  The Berkeley software License Agreement
 * specifies the terms and conditions for redistribution.
 *
 *	@(#)copy.c	7.1 (Berkeley) 6/5/86
 */

/*	#define BUFSIZE	10240	*/
#define BUFSIZE	512*17	/* tjt */

/*
 * Copy from --> to in 8.5K units.
 * Intended for use in system installation.
 */
main()
{
	int from, to;
	char buf[50];
	char buffer[BUFSIZE];
	register int record;
	extern int errno;
	int tjtrec;

	printf("\nStandalone Copy\n");	/* tjt */
	from = getdev("From", buf, 0);
	to = getdev("To", buf, 1);

	printf("Count of hd tracks: ");	/* tjt */
	gets(buf);
	tjtrec = atol(buf);

	for (record = 0; record < tjtrec ; record++) {
		int rcc, wcc;

		rcc = read(from, buffer, sizeof (buffer));
		if (rcc == 0)
			break;
		if (rcc < 0) {
			printf("Record %d: read error, errno=%d\n",
				record, errno);
			break;
		}
		if (rcc < sizeof (buffer))
			printf("Record %d: read short; expected %d, got %d\n",
				record, sizeof (buffer), rcc);
		/*
		 * For bug in ht driver.
		 */
		if (rcc > sizeof (buffer))
			rcc = sizeof (buffer);
		wcc = write(to, buffer, rcc);
		if (wcc < 0) {
			printf("Record %d: write error: errno=%d\n",
				record, errno);
			break;
		}
		if (wcc < rcc) {
			printf("Record %d: write short; expected %d, got %d\n",
				record, rcc, wcc);
			break;
		}
	}
/*	printf("Copy completed: %d records copied\n", record);	*/

	/* tjt - closing files turns off floppy motor */
	printf("Copy completed: %d tracks copied\n", record);
	close(from);
	close(to);
	/* can't call exit here */
}

getdev(prompt, buf, mode)
	char *prompt, *buf;
	int mode;
{
	register int i;

	do {
		printf("%s: ", prompt);
		gets(buf);
		i = open(buf, mode);
	} while (i <= 0);
	return (i);
}

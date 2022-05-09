/*
 * Copyright (c) 1982, 1986 Regents of the University of California.
 * All rights reserved.  The Berkeley software License Agreement
 * specifies the terms and conditions for redistribution.
 *
 *	@(#)prf.c	7.1 (Berkeley) 6/5/86
 */

/*
#include "../h/param.h"
*/
#include "../h/types.h"

#ifdef NEVER
/* used to test on the Sun-3 */
main()
{
	printf("num = %d %d\n",1234,5678);
	printf("long = %ld\n",1234L);
	printf("char = %c\n",0x33);
	printf("chars = %c\n",0x3334);
	printf("4chars = %c\n",0x31323334);
}
#endif

/*
 * Scaled down version of C Library printf.
 * Used to print diagnostic information directly on console tty.
 * Since it is not interrupt driven, all system activities are
 * suspended.  Printf should not be used for chit-chat.
 *
 * One additional format: %b is supported to decode error registers.
 * Usage is:
 *	printf("reg=%b\n", regval, "<base><arg>*");
 * Where <base> is the output base expressed as a control character,
 * e.g. \10 gives octal; \20 gives hex.  Each arg is a sequence of
 * characters, the first of which gives the bit number to be inspected
 * (origin 1), and the next characters (up to a control character, i.e.
 * a character <= 32), give the name of the register.  Thus
 *	printf("reg=%b\n", 3, "\10\2BITTWO\1BITONE\n");
 * would produce output:
 *	reg=2<BITTWO,BITONE>
 */
/*VARARGS1*/
printf(fmt, x1)
	char *fmt;
	unsigned x1;
{

	prf(fmt, &x1);
}

prf(fmt, adx)
	register char *fmt;
	register u_int *adx;
{
	register int b, c, i;
	char *s;
	int any;

loop:
	while ((c = *fmt++) != '%') {
		if(c == '\0')
			return;
		putchar(c);
	}
again:
	c = *fmt++;
	/* THIS CODE IS VAX DEPENDENT IN HANDLING %l? AND %c */
	/* (but it works fine on 680x0 with Sun C compilers) */
	/* (note that this %c may print more than one char)  */
	switch (c) {

	case 'l':
		goto again;
	case 'x': case 'X':
		b = 16;
		goto number;
	case 'd': case 'D':
	case 'u':		/* what a joke */
		b = 10;
		goto number;
	case 'o': case 'O':
		b = 8;
number:
		printn((u_long)*adx, b);
		break;
	case 'c':
		b = *adx;
		for (i = 24; i >= 0; i -= 8)
			if (c = (b >> i) & 0x7f)
				putchar(c);
		break;
	case 'b':
		b = *adx++;
		s = (char *)*adx;
		printn((u_long)b, *s++);
		any = 0;
		if (b) {
			while (i = *s++) {
				if (b & (1 << (i-1))) {
					putchar(any? ',' : '<');
					any = 1;
					for (; (c = *s) > 32; s++)
						putchar(c);
				} else
					for (; *s > 32; s++)
						;
			}
			if (any)
				putchar('>');
		}
		break;

	case 's':
		s = (char *)*adx;
		while (c = *s++)
			putchar(c);
		break;
	}
	adx++;
	goto loop;
}

/*
 * Printn prints a number n in base b.
 * We don't use recursion to avoid deep kernel stacks.
 */
printn(n, b)
	u_long n;
{
	char prbuf[11];
	register char *cp;

	if (b == 10 && (int)n < 0) {
		putchar('-');
		n = (unsigned)(-(int)n);
	}
	cp = prbuf;
	do {
		*cp++ = "0123456789abcdef"[n%b];
		n /= b;
	} while (n);
	do
		putchar(*--cp);
	while (cp > prbuf);
}

/* these hex functions added by tjt  3/2/91 */
#define HEX(x)	((x)<10 ? '0'+(x) : 'a'+(x)-10)

hex8(val)
long val;
{
	hex2(val>>24);
	hex2(val>>16);
	hex2(val>>8);
	hex2(val);
}

hex4(val)
{
	hex2(val>>8);
	hex2(val);
}

hex2(val)
{
	putchar(HEX((val>>4)&0xf));
	putchar(HEX(val&0xf));
}

/* Miniframe hardware definitions:
 * Here the "console" is channel A of the 7201 (8274) uart.
 */
struct mpuart {	/* first 4 "ports" are the 8274 */
	short	adata;
	short	bdata;
	short	astat;
	short	bstat;
	short	csel;
	short	pstat;
	short	reset;
};

#define GCR	((short *) 0x450000)		/* includes the LED's */
#define UART	((struct mpuart *) 0xc30000)
#define RCA	0x01	/* Receive char. available */
#define TBE	0x04	/* Transmitter buffer empty */

/* LED's  - writing a 1 turns it off!
 * 1 = near D connectors, 8 = furthest away.
 * do not count the center one (always on, power indicator).
 */
#define LIGHTS(x)	*GCR = (0x3000 | ((~x)<<8)&0x0f00)

/*
 * Print a character on console.
 */
putchar(c)
	register c;
{
	register timo;

	LIGHTS(4);
	timo = 30000;
	/*
	 * Try waiting for the console tty to come ready,
	 * otherwise give up after a reasonable time.
	 */
	while( ! (UART->astat & TBE) )
		if(--timo == 0)
			break;
	LIGHTS(8);
	UART->adata = c&0xff;
	if(c == '\n')
		putchar('\r');
}

getchar()
{
	register c;

	LIGHTS(1);
	while ( ! (UART->astat & RCA) )
		;
	LIGHTS(2);
	c = UART->adata & 0177;
	if (c=='\r')
		c = '\n';
	putchar(c);	/* echo */
	return(c);
}

gets(buf)
	char *buf;
{
	register char *lp;
	register c;

	lp = buf;
	for (;;) {
		c = getchar() & 0177;
		switch(c) {
		case '\n':
		case '\r':
			c = '\n';
			*lp++ = '\0';
			return;
		case '\b':
			if (lp > buf) {
				lp--;
				putchar(' ');
				putchar('\b');
			}
			continue;
		case '#':
		case '\177':
			lp--;
			if (lp < buf)
				lp = buf;
			continue;
		case '@':
		case 'u'&037:
			lp = buf;
			putchar('\n');
			continue;
		default:
			*lp++ = c;
		}
	}
}

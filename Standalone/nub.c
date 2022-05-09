/* echo - tjt 7/24/90
 *  simple test of routines in prf.c
 *  here used a a first test of the nub concept.
 *  12/3/90.
 */

char *prompt = "echo";

main()
{
	char buf[128];

	for ( ;; ) {
	    printf("%s: ", prompt);
	    gets(buf);
	    printf("got: %s\n", buf);
	}
}

/* called on startup to do hardware initialization */
configure()
{
	hwinit();
	printf("configure called\n");
}


/* "slow comm port" first 4 ports only are 8274 (7201) */
struct mpuart {
	short	adata;	/* 8274 -- channel A data */
	short	bdata;	/* 8274 -- channel B data */
	short	astat;	/* 8274 -- channel A status/cmd */
	short	bstat;	/* 8274 -- channel B status/cmd */
	short	csel;	/*   uart clock select */
	short	pstat;	/*   "port status" (hodge-podge of bits) */ 
	short	reset;	/*   8274 reset */
};

/* 8253 counter/timer - this one is used for baud rate generation */
struct timer {
	short	timera;	/* baud rate for uart channel A */
	short	timerb;	/* baud rate for uart channel B */
	short	timerc;	/* UNUSED */
	short	tcmd;	/* command register */
};

#define BAUD	((struct timer *) 0xc40000)
#define UART	((struct mpuart *) 0xc30000)

#define B38400	2
#define B19200	4
#define B9600	8
#define B1200	64

/* hwinit - do all the hardware initialization we can from C */
hwinit()
{
#ifdef 0
	sbaud(0,B38400);
	sbaud(1,B38400);
#else
	sbaud(0,B9600);
	sbaud(1,B9600);
#endif
	cini();
}

/* cini - initialize the UART hardware */
cini()
{
	UART->reset = 0;
	UART->csel = 0;
	UART->astat = 0x18;	/* 8274 reset */
	UART->astat = 0x18;	/* 8274 reset */
	UART->astat = 2;
		UART->astat = 0x00;	/* no interrupts */
	UART->astat = 4;
		UART->astat = 0x44;	/* 16x clock, 1 stop */
	UART->astat = 3;
		UART->astat = 0xC1;	/* enable Rcvr, 8bits data */
	UART->astat = 5;
		UART->astat = 0xEA;	/* enable Xmtr, 8bits, DTR, RTS */
	UART->astat = 1;
		UART->astat = 0x00;	/* no interrupts */
}

/* sbaud - set up the baud rate generator timer,
		the nop() calls are because the timer is so slow
		that we must avoid accessing it on successive machine cycles
*/
nop() {}

sbaud(chan,div)
{
	if ( chan == 0 ) {	/* Baud rate for UART channel A */
		BAUD->tcmd = 0x36;
		nop();
		BAUD->timera = div&0xff;	/* lsb first */
		nop();
		BAUD->timera = div>>8;
	} else {		/* for UART channel B */
		BAUD->tcmd = 0x76;
		nop();
		BAUD->timerb = div&0xff;	/* lsb first */
		nop();
		BAUD->timerb = div>>8;
	}

}

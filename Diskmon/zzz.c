/* dmon.c - disk based C monitor program for the Miniframe
 * this began as mon.c (the ROM based monitor)
 * mon.c was copied to dmon.c on 11/8/89.
 * Someday I will realize this was a bad idea, and diff the files,
 * and make a unified copy (with ifdef DMON for the differences?)
 */

/* keyword tokens - (some tokens just return their ascii value) */

#define CMD	0
#define	HEX	1

#define	K_DB	1
#define	K_DW	2
#define	K_DL	3
#define	K_MB	4
#define	K_MW	5
#define	K_ML	6

#define GCR	((short *) 0x450000)	/* where the LED's are */

/*
#define SLOWLED
*/

#ifdef TEST
#define LIGHTS(x)
#else

#ifdef SLOWLED
#define LIGHTS(x)	setled(x)
#else
#define LIGHTS(x)	*GCR = ( 0x3000 | (x<<8) )
#endif

#endif

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

#define RCA	0x01	/* 8274 - receive character available */
#define TBE	0x04	/* 8274 - transmitter buffer empty */

struct mregs {
	long	dr[8];
	long	ar[8];
	short	sr;
	long	pc;
	short	vec;
};

struct mregs romregs;
zoot()
{
	callrom(0x80027a,&romregs);
}

short autot;	/* auto-trace mode flag */
long nextadr;	/* address to start next memory dump (if defaulted) */ 
long bkadr;
unsigned short maxbk;
short nbkp;
short tcount;

#ifdef TEST
main()
{
	struct mregs dummy;

	dummy.sr = 0x2700;
	dummy.pc = 0;
	dummy.vec = 0x2020;
	for ( ;; ) {
	    if ( dummy.sr & 0x8000 )
		cttrap ( &dummy );
	    else
		cmon ( &dummy );
	}
}
#endif

#ifdef SLOWLED
setled(pat)
register pat;
{
	*GCR = ( 0x3000 | (pat<<8) );
	cdelay();
	cdelay();	/* .5 sec each */
	cdelay();
	cdelay();
}
#endif

cmon(regp)
register struct mregs *regp;
{

	LIGHTS(2);
	regp->pc = REENTER;	/* defined via -D in the makefile */ 
	hwinit();
	puts("\n68010 Miniframe DISK monitor 11/08/89\n");
	autot = 0;	/* not autotracing yet */
	tcount = 0;	/* trace count zero */
	nbkp = 0;	/* no breakpoints yet */
#ifdef TEST
	nextadr = 0x2020;
#else
	nextadr = 0;
#endif
	user(regp);
}

cutrap(regp)
register struct mregs *regp;
{
	short tvec;

	LIGHTS(15);
	tvec = regp->vec & 0xfff;
	puts("Exception vector ");
	puth(&tvec,2);
	puts(" at address ");
	puth(&regp->pc,4);
	putc('\n');
	user(regp);
}

cttrap(regp)
register struct mregs *regp;
{
	LIGHTS(15);
	if ( chkc() )
	    user(regp);
	if ( nbkp && --maxbk && regp->pc != bkadr )
	    return;
	puts("Trace: ");
	puth(&regp->pc,4);
	putc(' ');
	puth(regp->pc,16);
	putc('\n');
	if ( tcount && --tcount )
	    return;
	user(regp);
}

user(regp)
register struct mregs *regp;
{
	char *gets();
	char *line;
	int tok;
	int adr1, adr2;
	int temp;
	register char *adr;
	register data;

	LIGHTS(13);
	regp->sr &= 0x7fff;	/* trace flag off */
	rdump(regp);

	for ( ;; ) {
	    puts("TMON> ");
	    line = gets();
	    if ( getArg(&line,&tok,CMD) == -1 ) {	/* empty line */
		if ( autot ) {
		    regp->sr |= 0x8000;	/* trace on */
		    return;
		}
		continue;	/* quietly procede */
	    }
	    switch ( tok ) {
		case 'g':	/* go (run at PC) */
		    getArg(&line,&regp->pc,HEX);	/* optional */
		    if ( nbkp ) { /* set trace bit if bkpt active */
			regp->sr |= 0x8000;
			maxbk = 50000;
		    }
		    return;
		case 'r':	/* registers */
		    rdump(regp);
		    break;
		case 't':	/* trace (single step) */
		    temp = 0;
		    getArg(&line,&temp,HEX);
		    tcount = temp;
		    ++autot;
		    regp->sr |= 0x8000;
		    if ( nbkp )
			maxbk = 1;
		    return;
		case 'f':	/* fill */
		    if ( getArg(&line,&adr1,HEX) == -1 )
			puts("must give start and stop address\n");
		    if ( getArg(&line,&adr2,HEX) == -1 )
			puts("must give start and stop address\n");
		    if ( getArg(&line,&temp,HEX) == -1 )
			temp = 0;
		    data = temp;
		    for ( adr=(char *)adr1; adr<=(char *)adr2; ++adr )
			*adr = data;
		    break;
		case 'x':	/* set breakpoint */
		    if ( getArg(&line,&bkadr,HEX) == -1 ) {
			if ( nbkp ) {
			    puts("Breakpoint cleared\n");
			    nbkp = 0;	/* clear the breakpoint */
			}
		    } else 
			++nbkp;
		    break;
		case 'd':	/* memory dump */
		case K_DB:
		case K_DW:
		case K_DL:
		    if ( getArg(&line,&adr1,HEX) == -1 )
			adr1 = nextadr;
		    if ( getArg(&line,&adr2,HEX) == -1 )
			adr2 = adr1 + 0xff;
		    dump(adr1,adr2,tok);
		    nextadr = adr2+1;
		    break;
		case K_MB:
		case K_MW:
		case K_ML:
		    if ( getArg(&line,&adr1,HEX) == -1 )
			adr1 = nextadr;
		    modify(adr1,tok);
		    break;
		default:
		    puts("?unknown\n");
		    break;
	    }
	    autot = 0;
	}	/* never should return by falling out of here */
}

/* for now, just spaces are white space */
#define isspace(x)	( (x) == ' ' )

/* advance pointer past white space */
skipSp(lptr)
register char **lptr;
{
	while ( isspace(**lptr) )
		++*lptr;
}

getArg(lptr,value,typ)
register char **lptr;
long *value;
{
	skipSp(lptr);
	if ( **lptr == '\0' )
		return ( -1 );	/* Nada - he may use a default */
	/* notice that the above does not mess with value */

	if ( typ == CMD ) {	/* return a command token */
	    if ( **lptr == 'd' ) {
		++*lptr;
		if ( **lptr == 'b' )
		    *value = K_DB;
		else if ( **lptr == 'w' )
		    *value = K_DW;
		else if ( **lptr == 'l' )
		    *value = K_DL;
		else
		    *value = 'd';
	    } else if ( **lptr == 'm' ) {
		++*lptr;
		if ( **lptr == 'b' )
		    *value = K_MB;
		else if ( **lptr == 'w' )
		    *value = K_MW;
		else if ( **lptr == 'l' )
		    *value = K_ML;
		else
		    *value = 'm';
	    } else {
		*value = **lptr & 0xff;	/* just return first char */
	    }
	}
	else {	/* HEX is only other alternative at this time */
		*value = getaddr(*lptr);
	}

	/* clean out any other part of this word */
	while ( **lptr && ( ! isspace(**lptr) ) )
		++*lptr;
	return ( 0 );
}

long getaddr(b)
register char *b;
{
	register unsigned char c;
	register long addr = 0;

	while ( *b && *b == ' ' )
	    ++b;
	while ( c = *b++ ) {
		if ( c >= '0' && c <= '9' )
		    c -= '0';
		else if ( c >= 'a' && c <= 'f' )
		    c -= ('a'-10);
		else
		    break;
		addr <<= 4;
		addr |= c;
	}
	return ( addr );
}

#define PERLINE	16
dump(a1,a2,typ)
char *a1, *a2;
{
	register n, nn, nb, nl, nx;

	if ( typ == K_DB )
	    nb = 1;
	else if ( typ == K_DW )
	    nb = 2;
	else if ( typ == K_DL )
	    nb = 4;
	else {
	    for ( n = a2 - a1 + 1; n ; n -= nn ) {
		nn = (n>PERLINE) ? PERLINE : n;
		puth(&a1,4);
		puts("  ");
		puth(a1,nn);
		putc('\n');
		a1 += nn;
	    }
	    return;
	}

	for ( n = a2 - a1 + 1; n ; n -= nn ) {
	    puth(&a1,4);
	    puts("  ");
	    nn = (n>PERLINE) ? PERLINE : n;
	    for ( nl = nn; nl; nl -= nx ) {
		nx = (nl<nb) ? nl : nb;
		puth(a1,nx);
		a1 += nx;
		putc(' ');
	    }
	    putc('\n');
	}
}

modify(sadr,typ)
long sadr;
{
	int incr;
	char *adr;

	if ( typ == K_MB ) {
	    incr = 1;
	} else if ( typ == K_ML ) {
	    incr = 4;
	    sadr &= ~3;
	} else {
	    incr = 2;
	    sadr &= ~1;
	}

	for ( adr = (char *) sadr; ; adr += incr ) {
	    puth(&adr,4);
	    puts("  ");
	    puth(adr,incr);
	    putc(' ');
	    if ( getVal(adr,incr) )
		break;
	}
}

getVal(val,nval)
char *val;
{
	char *gets();
	long value;
	char *line;

	line = gets();
	skipSp(&line);
	if ( *line == '.' )
	    return ( 1 );
	if ( getArg(&line,&value,HEX) == -1 )
	    return ( 0 );	/* no change to value */

	if ( nval == 1 )
	    *val = value;
	else if ( nval == 4 )
	    *( (long *) val) = value;
	else	/* word by default */
	    *( (short *) val) = value;
	return ( 0 );
}

rdump(regp)
register struct mregs *regp;
{
	register i;
	register long *dp0, *dp4, *ap0, *ap4;

	LIGHTS(14);
	dp0 = &regp->dr[0];	/* to avoid 68020 code generation */
	dp4 = &regp->dr[4];
	ap0 = &regp->ar[0];
	ap4 = &regp->ar[4];
	for ( i=0; i<4; i++ ) {
		regout('d','0'+i,dp0++);
		regout('d','4'+i,dp4++);
		regout('a','0'+i,ap0++);
		regout('a','4'+i,ap4++);
		putc('\n');
	}
	regout('p','c',&regp->pc);
	puts("   sr: ");
	puth(&regp->sr,2);
	putc('\n');

}

regout(typ,num,val)
char *val;
{
	puts("   ");
	putc(typ);
	putc(num);
	puts(": ");
	puth(val,4);
}

/******* Support routines follow ***************************/
#define B9600	8
#define B1200	64

/* hwinit - do all the hardware initialization we can from C */
hwinit()
{
#ifndef TEST
	LIGHTS(3);
	sbaud(0,B9600);
	sbaud(1,B9600);
	cini();
#endif
}

#ifndef TEST
/* cini - initialize the UART hardware */
cini()
{
	LIGHTS(4);
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
	LIGHTS(5);
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
#endif

#define GETSBUFSIZE	128
char *gets()
{
	static char buf[GETSBUFSIZE];
	register unsigned char c;
	register char *line = buf;

	LIGHTS(6);
	while ( (c = getc()) != '\n' ) {	/* force lower case */
	    if ( c >= 'A' && c <= 'Z' )
		c += ('a'-'A');
	    if ( line < &buf[GETSBUFSIZE-1] )	/* insurance */
		*line++ = c;
	}
	*line = '\0';
	return ( buf );
}

/* chkc - check for a keypress, never block, throw it away */
#ifdef TEST
chkc() { return (0); }
#else
chkc()
{
	register c;

	if ( ! (UART->astat & RCA) )
	    return (0);
	c = UART->adata & 0x7f;	/* get rid of it, no echo */
	chkc();		/* get rid of everything, recursion */
	return (1);
}
#endif

/* getc - simple polled character input */
#ifdef TEST
getc() { return (tgetchar()); }
#else
getc()
{
	register c;

	LIGHTS(7);
	while ( ! (UART->astat & RCA) )
	    ;
	LIGHTS(12);
	c = UART->adata & 0x7f;
	if ( c == '\r' )
	    c = '\n';
	putc(c);	/* echo */
	return ( c );
}
#endif

puth(b,n)
register char *b;
register n;
{
	register unsigned char t;

	LIGHTS(8);
	while ( n-- ) {
		t = (*b>>4) & 0xf;
		putc ( (t<10) ? '0'+t : 'A'+(t-10) );
		t = *b++ & 0xf;
		putc ( (t<10) ? '0'+t : 'A'+(t-10) );
	}
}

puts(s)
register unsigned char *s;
{
	LIGHTS(9);
	while ( *s )
		putc ( *s++ );
}

#ifdef TEST
putc(c) { tputchar(c); }
#else
/* On the Sun-3, '\n' is a 0x0a and '\r' is a 0x0d, if some other
 * fish-brained system makes them equal we are in for trouble */
putc(c)
{
	LIGHTS(10);
	while ( ! (UART->astat & TBE) )
		;
	LIGHTS(11);
	UART->adata = c;
	if ( c == '\n' )
		putc('\r');	/* recursive ! */
}
#endif

/* END */

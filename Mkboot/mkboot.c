/* mkboot - write a bootable disk image for the
 * Convergent Technologies miniframe computer
 * T. Trebisky  8/22/89
 * MSDOS (Rainbow) version begun 11/26/90
 * Rainbow interleave bug fixed 1/20/91
 * This version running on PC/AT using RX50drvr  4/91
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

#define NSPT	10	/* Rx50 sectors per tracks */
#define NHEADS	1	/* Rx50 number of heads (sides) */
#define PCYL	5	/* cylinder where "partition" starts */

#ifdef NEVER
/* here are features we are NOT using */
#define DEBUG
#else
/* here are features we ARE using */
#endif

#include <fcntl.h>
#define OFLAGS (O_RDONLY|O_BINARY)
typedef unsigned long ulong;
struct exec {
	long	a_magic;	/* number identifies as .o file and gives type of such. */
	ulong   text;		/* length of text, in bytes */
	ulong   data;		/* length of data, in bytes */
	ulong   bss;		/* length of uninitialized data area for file, in bytes */
	ulong   syms;		/* length of symbol table data in file, in bytes */
	ulong   entry;		/* start address */
	ulong   trsize;		/* length of relocation info for text, in bytes */
	ulong   drsize;		/* length of relocation info for data, in bytes */
} header;
#define HDRSIZE	sizeof(struct exec)

#ifdef NOT_MSDOS
/* Back in the old days, on the sun, the a.out.h file was
 * appropriate, but not on a modern linux system.
 */
#include <a.out.h>
struct bhdr header;
#define HDRSIZE	sizeof(struct bhdr)	/* Callan edition 7 unix */
/* If you can believe it, the Callan byte swaps every sector it writes
 * to the floppy disk - fine for the Callan, but a mess for us, the following
 * switch invokes byte-swapping logic as we write on that machine.
 */
#define OFLAGS 0
#define CALLAN
int ofd;	/* output disk file */
#endif

#ifdef MSDOS
#include <dos.h>
#include <fcntl.h>
#define OFLAGS (O_RDONLY|O_BINARY)
typedef unsigned long ulong;
struct exec {
	long	a_magic;	/* number identifies as .o file and gives type of such. */
	ulong   text;		/* length of text, in bytes */
	ulong   data;		/* length of data, in bytes */
	ulong   bss;		/* length of uninitialized data area for file, in bytes */
	ulong   syms;		/* length of symbol table data in file, in bytes */
	ulong   entry;		/* start address */
	ulong   trsize;		/* length of relocation info for text, in bytes */
	ulong   drsize;		/* length of relocation info for data, in bytes */
} header;
#define HDRSIZE	sizeof(struct exec)
#endif

struct ctsup {
	long	magic;		/* word 1-2 of 512 */
	short	fill0[6];	/* words 3-8 */
	short	nheads;		/* word 9 0x3010 --> a0@(0xa) */
	short	sectrk;		/* word 10 0x3012 */
	short	seccyl;		/* word 11 0x3014 */
	char	flags;		/* word 12 0x3016 */
	char	hdseek;
	short	fill1[33];	/* word 13-45 0x3018 never used */
	long	ldrptr;		/* word 46-49 */
	short	ldrcnt;	
	long	hdbptr;		/* word 52-55 */
	short	hdbcnt;
	long	dmpptr;		/* word 58-61 */
	short	dmpcnt;
	short	fill2[456];	/* word 64-511 */
	long	cksum;		/* word 511-512 */
} sblock;

/* The i/o for the boot image is done in 1K granules,
 * in particular, note that the size of the super-block (boot-block)
 * must be a 1K unit (this is verified below).
 */
#define SSIZE 512	/* sector size */
#define KSECS 2		/* sectors per K unit */
#define KSIZE (KSECS*SSIZE)	/* 1K unit */

char imbuf[KSIZE];

long lfix();
short sfix();
long lsum();

main(argc,argv)
char **argv;
{
	long imsize;
	int imblocks;
/*	struct stat sbuf;	*/
	int infd;
	int i;
	int num;
#ifdef DEBUG
	int bnum;
#endif

	--argc;
	++argv;
#ifdef MSDOS
	if ( argc < 1 )
		error("usage: mkboot aoutfile");
#else
	if ( argc != 2 )
		error("usage: mkboot aoutfile bootfile");
#endif

	if ( sizeof(struct ctsup) != KSIZE )
		error("Superblock structure malformed\n");
	if ( (infd = open(argv[0],OFLAGS)) == -1 )
		error("Cannot open input (a.out) file");

	if ( read(infd,&header,HDRSIZE) != HDRSIZE )
		error("Cannot read a.out header");
/*	if ( fstat(infd,&sbuf) == -1 )
 *		error ("Cannot access input file");
 *
 *	imsize = sbuf.st_size - HDRSIZE;
 *	printf("%ld bytes in image\n",imsize);
 */
	printf("text size: %ld\n",lfix(header.text));
	printf("data size: %ld\n",lfix(header.data));
	printf("text + data = %ld\n",lfix(header.text)+lfix(header.data));
	printf("bss size: %ld\n",lfix(header.bss));	/* just info now */
	imsize = lfix(header.text)+lfix(header.data);
	imblocks = (imsize+KSIZE-1) / KSIZE;
	printf("image uses %d 1K blocks\n",imblocks);
#ifdef DEBUG
	imblocks = 40;
#endif
	
	zfill ( (char *) &sblock, KSIZE );

	sblock.magic = lfix((long)0x55515651);	/* 'UQVQ' */
#ifdef MSDOS
	/* proper parameters for a Rainbow RX50 floppy */
	sblock.nheads = sfix(NHEADS);
	sblock.sectrk = sfix(NSPT);
	sblock.seccyl = sfix(NHEADS*NSPT);
#else
	sblock.nheads = sfix(2);	/* number of heads (sides) */
	sblock.sectrk = sfix(8);	/* sectors per track */
	sblock.seccyl = sfix(16);	/* sectors per cylinder */
#endif
	sblock.flags = 1;		/* double density floppy */
	sblock.ldrptr = lfix( (long) 1);
	sblock.ldrcnt = sfix(imblocks);
	sblock.cksum = lfix ( (long) (-1) -
			lsum ( (long *) &sblock, (KSIZE/sizeof(long))-1 ));

#ifndef MSDOS
	if ( (ofd = creat(argv[1],0644)) == -1 )
		error("Cannot open output file");
#endif

	dseek ( 0 );
	dwrite( (char *) &sblock );
	if ( lseek ( infd, (long) HDRSIZE, 0 ) == -1 )
		error ("Seek error");

#ifdef DEBUG
	bnum = 2;
	for ( i=0; i<imblocks; i++ ) {
		for ( num=0; num<512; num++ )
			imbuf[num] = bnum;
		bnum++;
		for ( num=512; num<1024; num++ )
			imbuf[num] = bnum;
		bnum++;
		dwrite ( imbuf );
	}
#else
	for ( i=0; i<imblocks-1; i++ ) {
		num = read(infd,imbuf,KSIZE);
		if ( num != KSIZE ) {
			printf("read returns %d\n",num);
			error("Read error");
		}
		dwrite ( imbuf );
	}
	/* write a complete last block */
	zfill(imbuf,KSIZE);
	if ( (num = read(infd,imbuf,KSIZE)) <= 0 )
		error("final read error");
	dwrite ( imbuf );
	close(infd);
#endif

#ifdef MSDOS
	dseek ( PCYL * NSPT );
	if ( argc > 1 ) {
		if ( (infd = open(argv[1],OFLAGS)) == -1 )
			error("Cannot open input (fs) file");
		for ( i=0; ; ) {
			if ( num = read(infd,imbuf,KSIZE) ) {
				dwrite ( imbuf );
				++i;
			} else
				break;	/* EOF */
			if ( num != KSIZE ) {
				printf("last fs read returned %d\n",num);
				break;
			}
		}
		printf("%d fs blocks copied\n",i);
		close(infd);
	}
#else
	close(ofd);
#endif
	exit(0);
}

zfill(buf,nby)
register char *buf;
register nby;
{
	while ( nby-- )
		*buf++ = 0;
}

long
lsum (buf, nlong)
register long *buf;
register nlong;
{
	unsigned long sum = 0;

	while ( nlong-- )
		sum += lfix(*buf++);
	return ( sum );
}

short 
sfix(inword)
{
#ifdef MSDOS
	register tmp;

	tmp = inword;
	inword = (tmp&0xff)<<8 | (tmp>>8)&0xff;
#endif
	return(inword);
}

long 
lfix(inlong)
long inlong;
{
#ifdef MSDOS
	union {
		long	tlong;
		char	clong[4];	/* the ultimate in portability */
	} tu;
	register char tmp;

	tu.tlong = inlong;
	tmp = tu.clong[0];
	tu.clong[0] = tu.clong[3];
	tu.clong[3] = tmp;
	tmp = tu.clong[1];
	tu.clong[1] = tu.clong[2];
	tu.clong[2] = tmp;
	return(tu.tlong);
#else
	return(inlong);
#endif

}

error(s)
char *s;
{
	fprintf(stderr,"%s\n",s);
	exit(1);
}

bswap(buf,n)
register char *buf;
register n;
{
	register t;

	for ( ; n ; n -= 2 ) {
		t = *buf;
		*buf = buf[1];
		buf[1] = t;
		buf += 2;
	}
}

/* bsize must be an integral number of sectors, at present
 * bsize is always 1024 bytes (KSIZE) in this program.
 */
#ifdef CALLAN
dwrite(buf)
char *buf;
{
	bswap(buf,KSIZE);
	if ( write ( ofd, buf, KSIZE ) != KSIZE )
		error("Write error");
}
#else
/* this code is specific to the Rainbow.
 * (it would be generic MSDOS except for the Rainbow interleave stuff.)
 */
static short nextsec = 0;

dseek(newsec)
{
	nextsec = newsec;
}

#define A_DISK	0	/* A: */
#define B_DISK	1	/* B: */
#define D_DISK	3	/* D: */

#define DRIVE	D_DISK	/* proper for use with RX50DRVR on the AT */

#define AD_WRITE 0x26	/* Absolute Disk Write is INT 26H */

static char secmap[] = { 0, 5, 1, 6, 2, 7, 3, 8, 4, 9 };

dwrite(buf)
char *buf;
{
	int track;

	track = nextsec / NSPT;
	if ( track < 2 )	/* first two tracks are 1:1 interleave */
		swrite(buf,nextsec);
	else
		swrite(buf,track*NSPT + secmap[nextsec%NSPT]);

	track = ++nextsec / NSPT;
	if ( track < 2 )
		swrite(&buf[SSIZE],nextsec);
	else
		swrite(&buf[SSIZE],track*NSPT + secmap[nextsec%NSPT]);
	++nextsec;
}

swrite(buf, secabs)
char *buf;
{
	union REGS inregs, outregs;

	inregs.h.al = DRIVE;	/* write to A: */
	inregs.x.cx = 1;	/* write one 512 byte unit */
	inregs.x.dx = secabs;
/*
 * This would be fine if buf was a (far char *).
 *	inregs.x.bx = FP_OFF(buf);
 */
	inregs.x.bx = (unsigned int) buf;	/* Yuk! */

	printf("Writing sector %d (to %d)\n",nextsec,secabs);

	int86 ( AD_WRITE, &inregs, &outregs );
	/* one uncertain aspect of this call is that it leaves the flags
	   on the stack when it returns (why, WHY? I ask you), there is no
	   clean way to tidy this up in C, but I expect that the subroutine
	   epilog will get things straightened up.
	*/

	if ( outregs.x.cflag ) {
		printf("error writing sector %d\n",nextsec);
		printf("cflag = %04x\n",outregs.x.cflag);
		printf("   ax = %04x\n",outregs.x.ax);
		exit(1);
	}
}
#endif
/* END */

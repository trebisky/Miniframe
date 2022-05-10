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

#include <unistd.h>
#include <stdlib.h>

/* We are running on a little endian intel machine,
 * wo we need to byte swap.
 */
#define SWAP

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
// #define OFLAGS (O_RDONLY|O_BINARY)
#define OFLAGS (O_RDONLY)

/* On a modern linux machine, int is 4 bytes and long is 8 bytes.
 * we want nothing to do with 8 byte longs in this software.
 */
// typedef unsigned long ulong;

typedef int int4;
typedef unsigned int u_int4;

struct exec {
	int4	a_magic;	/* number identifies as .o file and gives type of such. */
	u_int4   text;		/* length of text, in bytes */
	u_int4   data;		/* length of data, in bytes */
	u_int4   bss;		/* length of uninitialized data area for file, in bytes */
	u_int4   syms;		/* length of symbol table data in file, in bytes */
	u_int4   entry;		/* start address */
	u_int4   trsize;		/* length of relocation info for text, in bytes */
	u_int4   drsize;		/* length of relocation info for data, in bytes */
} header;
#define HDRSIZE	sizeof(struct exec)

int ofd;	/* output disk file */

struct ctsup {
	int4	magic;		/* word 1-2 of 512 */
	short	fill0[6];	/* words 3-8 */
	short	nheads;		/* word 9 0x3010 --> a0@(0xa) */
	short	sectrk;		/* word 10 0x3012 */
	short	seccyl;		/* word 11 0x3014 */
	char	flags;		/* word 12 0x3016 */
	char	hdseek;
	short	fill1[33];	/* word 13-45 0x3018 never used */
	int4	ldrptr;		/* word 46-49 */
	short	ldrcnt;	
	int4	hdbptr;		/* word 52-55 */
	short	hdbcnt;
	int4	dmpptr;		/* word 58-61 */
	short	dmpcnt;
	short	fill2[456];	/* word 64-511 */
	int4	cksum;		/* word 511-512 */
} __attribute__((packed));

struct ctsup sblock;

/* The i/o for the boot image is done in 1K granules,
 * in particular, note that the size of the super-block (boot-block)
 * must be a 1K unit (this is verified below).
 */
#define SSIZE 512	/* sector size */
#define KSECS 2		/* sectors per K unit */
#define KSIZE (KSECS*SSIZE)	/* 1K unit */

/* Byte swap a short */
short 
sfix( int inword )
{
#ifdef SWAP
	int tmp;

	tmp = inword;
	inword = (tmp&0xff)<<8 | (tmp>>8)&0xff;
#endif
	return(inword);
}

int4 
lfix( int4 inlong )
{
#ifdef SWAP
	union {
		int4	tlong;
		char	clong[4];	/* the ultimate in portability */
	} tu;
	char tmp;

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

#ifdef notdef
int4
lsum ( int4 *buf, int nlong)
{
	unsigned int sum = 0;

	while ( nlong-- )
		sum += lfix(*buf++);
	return ( sum );
}
#endif

int4
lsum ( char *buf, int nlong)
{
	unsigned int sum = 0;
	int4 *ip;

	ip = (int4 *) buf;
	while ( nlong-- )
		sum += lfix(*ip++);
	return ( sum );
}

void
zfill ( char *buf, int nby)
{
	while ( nby-- )
		*buf++ = 0;
}

void
bswap ( char *buf, int n )
{
	int t;

	for ( ; n ; n -= 2 ) {
		t = *buf;
		*buf = buf[1];
		buf[1] = t;
		buf += 2;
	}
}

void
error ( char *s )
{
	fprintf(stderr,"%s\n",s);
	exit(1);
}

/* bsize must be an integral number of sectors, at present
 * bsize is always 1024 bytes (KSIZE) in this program.
 */
int
dwrite ( char *buf )
{
	bswap(buf,KSIZE);
	if ( write ( ofd, buf, KSIZE ) != KSIZE )
		error("Write error");
}

/* --------------------------------------------------------------------------------- */
/* --------------------------------------------------------------------------------- */
/* --------------------------------------------------------------------------------- */

char imbuf[KSIZE];

int
main ( int argc, char ** argv )
{
	int4 imsize;
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

	// printf ( "int = %d\n", sizeof(int) );
	// printf ( "long = %d\n", sizeof(long) );

	if ( argc != 2 )
		error("usage: mkboot aoutfile bootfile");

	if ( sizeof(struct ctsup) != KSIZE ) {
	    fprintf ( stderr, "Superblock = %d bytes\n", sizeof(struct ctsup) );
	    error("Superblock structure malformed\n");
	}

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

	sblock.magic = lfix((int4)0x55515651);	/* 'UQVQ' */
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
	sblock.ldrptr = lfix( (int4) 1);
	sblock.ldrcnt = sfix(imblocks);
	sblock.cksum = lfix ( (int4) (-1) -
			lsum ( (char *) &sblock, (KSIZE/sizeof(int4))-1 ));

	/* Create output file */
	if ( (ofd = creat(argv[1],0644)) == -1 )
		error("Cannot open output file");

	dwrite( (char *) &sblock );
	if ( lseek ( infd, (int4) HDRSIZE, 0 ) == -1 )
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

	close(ofd);

	exit(0);
}

/* END */

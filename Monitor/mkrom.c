#include <stdio.h>
#include <sys/file.h>
#include <a.out.h>

/* mkrom.c
 * Program to patch Convergent Technologies boot ROM's
 * These rom's have code for the 68000 (68010) split into even/odd bytes
 * The 72-00356 ROM has the even bytes (rom56.hex) (al.hex or bl.hex)
 * The 72-00357 ROM has the odd bytes  (rom57.hex) (ar.hex or br.hex)
 * Both have been read out in Intel Hex format
 *
 * This program reads and merges the two hex files.
 * Then it applies a "patch" file and regenerates output hex files.
 * These can then be used to burn new roms.
 * T. Trebisky 8/28/89
 */

/*  ROM filenames -- now generated internally (below)
*/
char evenfile[16];
char oddfile[16];

char *mfile;		/* a.out image of my monitor */

/* output file names */

char *ofile = "orom.hex";
char *efile = "erom.hex";

#define ROMSIZE	8*1024	/* 2764 EPROMS are 8K */
#define IMSIZE	2*ROMSIZE
char image[IMSIZE];

struct exec hdr;

long	patch_offset;
long	mon_offset;

/* this fix stuff added 12/26/90 - I had noticed this before in the
 * ROM disassembly, now am getting address errors from this bad code.
 * So I will fix it and burn new roms (this code is entered only when
 * there are i/o errors from the floppy controller chip.)
 */
long	fix_offset = 0xc00;	/* 0x800c00 */
short	old_fix = 0x4eb1;
short	new_fix = 0x4eb9;

main(argc,argv)
char **argv;
{
	int byt;
	int loc;
	int i, fd;
	int nmon, jump;
	char filetyp = 'b';	/* default rom set */
	short fixtmp;

	--argc;
	++argv;
	if ( argc != 4 )
	    error("usage: mkrom a|b patchaddr monaddr a.out");

	if ( **argv == 'a' || **argv == 'A' )
	    filetyp = 'a';
	else if ( **argv == 'b' || **argv == 'B' )
	    filetyp = 'b';
	else
	    error("usage: mkrom a|b patchaddr monaddr a.out");

	++argv;
	patch_offset = strtol( *argv, (char **)NULL, 0);
	++argv;
	mon_offset = strtol( *argv, (char **)NULL, 0);
	++argv;
	mfile = *argv;

/* 
 * Read the two ROM files into the memory image array
 */

	sprintf(evenfile,"../%cl.hex",filetyp);
	if ( hexopen(evenfile) == -1 )
		error("cannot open %s",evenfile);
	loc = 0;
	while ( (byt=getby()) != EOF ) {
		image[loc] = byt;
		loc += 2;
	}
	hexclose();
	printf("even bytes read from: %s\n",evenfile);

	sprintf(oddfile,"../%cr.hex",filetyp);
	if ( hexopen(oddfile) == -1 )
		error("cannot open %s",oddfile);
	loc = 1;
	while ( (byt=getby()) != EOF ) {
		image[loc] = byt;
		loc += 2;
	}
	hexclose();
	printf(" odd bytes read from: %s\n",oddfile);

/*
 * OK - patch the image in memory
 */
	printf("patch offset: %08.8x\n",patch_offset);
	if ( patch_offset < 0x800000 || patch_offset >= 0x800000 + IMSIZE )
		error("patch offset out of range");
	patch_offset -= 0x800000;

	if ( (fd=open(mfile,O_RDONLY)) == -1 )
		error("cannot open %s",mfile);
	if ( read(fd,&hdr,sizeof(hdr)) != sizeof(hdr) )
		error("cannot read a.out header");

	printf("monitor entry: %08.8x\n",mon_offset);
	if ( mon_offset < 0x800000 || mon_offset >= 0x800000 + IMSIZE )
		error("monitor entry out of range");
	mon_offset -= 0x800000;

	nmon = hdr.a_text + hdr.a_data;
	if ( mon_offset+nmon >= IMSIZE )
		error ("monitor too big!!");
	printf("monitor size = %d bytes\n",nmon);
	printf("last address in monitor %08.8x\n",0x800000+mon_offset+nmon-1);
	printf("last address in ROM %08.8x\n",0x800000+IMSIZE-1);
	printf("%d bytes left in ROM's\n",IMSIZE-nmon-mon_offset);

#define NPATCH	4
	if ( patch_offset+NPATCH > mon_offset )
	    error ("patch overlaps monitor!!");

	/* Here we "hand assemble" the instruction bsr monitor_entry */
	image[patch_offset] = 0x61;	/* OP code for a.... */
	image[patch_offset+1] = 0x00;	/* bsr instruction */
	jump = mon_offset - (patch_offset+2);
	image[patch_offset+2] = (jump>>8);	/* high byte */
	image[patch_offset+3] = jump;		/* low byte */

	if ( read(fd,&image[mon_offset],nmon) != nmon )
	    error("cannot read monitor image");
	close(fd);

	fixtmp = image[fix_offset]<<8 | image[fix_offset+1] & 0xff;
	if ( fixtmp != old_fix )
	    error("bad value at fix location: %04x\n",fixtmp);
	image[fix_offset] = new_fix>>8;
	image[fix_offset+1] = new_fix;
/*
 * OK - have a patched memory image - write it out
 */

	if ( iopen(efile) == -1 )
	    error("cannot open %s",efile);

	for ( loc=0; loc<IMSIZE; loc+=2 )
	    iputc(image[loc]);

	iclose();

	if ( iopen(ofile) == -1 )
	    error("cannot open %s",ofile);

	for ( loc=1; loc<IMSIZE; loc+=2 )
	    iputc(image[loc]);

	iclose();
	exit(0);
}

/**********************************************************************
 * Routines follow to read an intel hex file
 **********************************************************************/

#define MAXLINE 128

FILE	*infile;
int	lineno;
char	lbuf[MAXLINE];	/* current input line exactly as read */
char	bbuf[MAXLINE];	/* bytes from current input line */
int	nby;		/* bytes remaining in bbuf[] */
char	*pby;		/* pointer to next byte in bbuf */

hexopen(name)
char *name;
{
	if ( (infile=fopen(name,"r")) == NULL )
		return ( -1 );
	lineno = 0;
	nby = 0;
	return ( 0 );
}

hexclose()
{
	fclose(infile);
}

getby()
{
	while ( nby <= 0 ) {
		if ( (nby=rline()) < 0 )
			return ( EOF );
		pby = bbuf;
	}
	--nby;
	return ( *pby++ & 0xff );
}

/* read a line in Intel Load Module Format, notice that we ignore
 * some of the info (start, flag, and checksum), and make the assumption
 * that the lines are contiguous addresses, beginning at zero.
 * This could easily be generalized.
 */
rline()
{
	char *p, *q;
	int c;
	int num, slen;
	int start;
	int flag;
	int i, j;

	p = lbuf;
	while ( (c=getc(infile)) != EOF && c != '\n' ) {
		if ( p >= &lbuf[MAXLINE-1] )
			trouble("Input line too long");
		else
			*p++ = c;
	}
	*p = '\0';
	if ( c == EOF && p == lbuf )
		return ( EOF );
	++lineno;

	/* OK, got a line of input -- see if it is really in
		Intel load module format */
	
	if ( lbuf[0] != ':' )
		trouble("Not in Intel LM format");
	if ( (slen=strlen(lbuf)) < 11 )
		trouble("Not in Intel LM format");
	num = hexc ( lbuf[1], lbuf[2] );
	start = hexc ( lbuf[3], lbuf[4] );
	start = start<<8 | hexc ( lbuf[5], lbuf[6] );
	flag = hexc ( lbuf[7], lbuf[8] );
	if ( slen != (num*2 + 11 ) )
		trouble("Not in Intel LM format");
	j = 9;
	for ( i=0; i<num; ++i ) {
		bbuf[i] = hexc ( lbuf[j], lbuf[j+1] );
		j += 2;
	}
	return ( num );
}

hexc(d1,d2)
{
	return ( h2i(d1)<<4 | h2i(d2) );
}

h2i(hchar)
{
	if ( hchar >= '0' && hchar <= '9' )
		return ( hchar - '0' );		/* better be ascii */
	else if ( hchar >= 'a' && hchar <= 'f' )
		return ( hchar - 'a' + 10 );
	else if ( hchar >= 'A' && hchar <= 'F' )
		return ( hchar - 'A' + 10 );
	else
		trouble("Not a hex digit");
}
/**********************************************************************
 * Routines follow to write an intel hex file
 **********************************************************************/

FILE *ifd;
#define NINTEL	16	/* bytes in an intel hex record */
char ibuf[NINTEL];
int nbuf;
unsigned short iaddr; 
int csum;		/* build checksum here */

iopen(fname)
char *fname;
{
	if ( (ifd = fopen(fname,"w")) == NULL )
		return ( -1 );
	nbuf = 0;
	iaddr = 0;	/* begin at address 0x0000 */
	return ( 0 );
}

iputc(c)
{
	ibuf[nbuf++] = c;
	if ( nbuf >= NINTEL ) {
		iputs(ibuf,nbuf);
		iaddr += nbuf;
		nbuf = 0;
	}
}

iclose()
{
	if ( nbuf )
		iputs(ibuf,nbuf);
	fprintf(ifd,":00000001FF\n");	/* the EOF line */
	fclose(ifd);
}

iputs(buf,n)
register char *buf;
register n;
{
	static unsigned char cbuf;

	csum = 0;		/* clean it out */
	fputc(':',ifd);
	cbuf = n;
	iputh(&cbuf,1);		/* data bytes in this record */
	iputw(iaddr);		/* start address for record */
	cbuf = 0;		/* data type */
	iputh(&cbuf,1);
	iputh(buf,n);		/* the data */
	cbuf = -csum;		/* want 2's complement */
	iputh(&cbuf,1);
	fputc('\n',ifd);
}

iputh(b,n)
register char *b;
register n;
{
	register t;
	register c;

	while ( n-- ) {
		c = *b++ & 0xff;
		csum += c;

		t = (c>>4)&0xf;
		fputc( (t<10) ? '0'+t : 'A'+(t-10), ifd );

		t = c&0xf;
		fputc( (t<10) ? '0'+t : 'A'+(t-10), ifd );
	}
}

/* output a short (portable on a byte-swapped machine) */
iputw(w)
register short w;
{
	register t;
	register c;
	register n = 2;

	while ( n-- ) {
		if ( n )
		    c = w>>8 & 0xff;
		else
		    c = w & 0xff;

		csum += c;

		t = (c>>4)&0xf;
		fputc( (t<10) ? '0'+t : 'A'+(t-10), ifd );

		t = c&0xf;
		fputc( (t<10) ? '0'+t : 'A'+(t-10), ifd );
	}
}

/**********************************************************************
 * General Error Routines follow
 **********************************************************************/

trouble(msg)
char *msg;
{
	fprintf(stderr,"Error, %s\n",msg);
	fprintf(stderr," Line %d\n",lineno);
	fprintf(stderr," %s\n",lbuf);
	exit(1);
}

error(f,s)
char *f, *s;
{
	fprintf(stderr,f,s);
	fprintf(stderr,"\n");
	exit(1);
}

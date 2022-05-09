#include <stdio.h>
#include <sys/file.h>
#include <a.out.h>
/* Special program to deal with Convergent Technologies ROM's
 * These have code for the 68000 (68010) split into even/odd bytes
 * The 72-00356 ROM has the even bytes (rom56.hex) (al.hex or bl.hex)
 * The 72-00357 ROM has the odd bytes  (rom57.hex) (ar.hex or br.hex)
 * Both have been read out in Intel Hex format
 */

#define MAXLINE 128

int	lineno = 0;
char	lbuf[MAXLINE];	/* current input line exactly as read */
char	bbuf[MAXLINE];	/* bytes from current input line */
int	nby = 0;	/* bytes remaining in bbuf[] */
char	*pby;		/* pointer to next byte in bbuf */

FILE *infile;
int fout;

/*
char *evenfile = "rom56.hex";
char *oddfile = "rom57.hex";
char *evenfile = "bl.hex";
char *oddfile = "br.hex";
*/
char *evenfile = "al.hex";
char *oddfile = "ar.hex";

char *outfile = "conv.out";

#define ROMSIZE	8*1024	/* 2764 EPROMS are 8K */
#define IMSIZE	2*ROMSIZE
struct exec hdr;
char image[IMSIZE];

main()
{
	int byt;
	int loc;

	if ( (infile=fopen(evenfile,"r")) == NULL )
		error("cannot open %s",evenfile);
	loc = 0;
	while ( (byt=getby()) != EOF ) {
		image[loc] = byt;
		loc += 2;
	}
	fclose(infile);
	if ( (infile=fopen(oddfile,"r")) == NULL )
		error("cannot open %s",oddfile);
	loc = 1;
	while ( (byt=getby()) != EOF ) {
		image[loc] = byt;
		loc += 2;
	}
	fclose(infile);

	hdr.a_machtype = M_68010;
	hdr.a_magic = OMAGIC;
	hdr.a_text = IMSIZE;
	hdr.a_data = 0;
	hdr.a_bss = 0;
	hdr.a_syms = 0;
	hdr.a_entry = 0x800000;
	hdr.a_trsize = 0;
	hdr.a_drsize = 0;

	creat(outfile,0664);
	if ( (fout = open(outfile,O_WRONLY)) == -1 )
		error("cannot write %s",outfile);
	write(fout,&hdr,sizeof(hdr));
	write(fout,image,IMSIZE);
	close(fout);

/*
	for ( loc=0; loc<IMSIZE; loc += 2 ) {
		printf("%04.4x\t",loc);
		printf("%02.2x%02.2x\n",image[loc]&0xff,image[loc+1]&0xff);
	}
*/
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

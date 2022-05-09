#include <stdio.h>
#include <sys/file.h>
#include <a.out.h>

/* 
 * Post-processor program - confmt.c
 * Special program to deal with Convergent Technologies ROM's
 * read the file dissassembled by "adb"
 * add hex and character output.
 */

int binfd;
FILE *adbfp;
FILE *outfp;

char *binfile = "conv.out";
char *adbfile = "conv.dis";
char *outfile = "conv.fmt";

#define ROMSIZE	8*1024	/* 2764 EPROMS are 8K */
#define IMSIZE	ROMSIZE
struct exec hdr;
short image[IMSIZE];

#define MAXLINE 128

char aline[MAXLINE];

main()
{
	long aloc, bloc;
	int index;
	char *rline;
	int nblank;

	if ( (binfd = open(binfile,O_RDONLY)) == -1 )
		error("cannot read %s",binfile);
	read (binfd,&hdr,sizeof(hdr));
	read (binfd,image,IMSIZE);
	index = 0;
	close (binfd);

	if ( (adbfp=fopen(adbfile,"r")) == NULL )
		error("cannot open %s",adbfile);
	if ( (outfp=fopen(outfile,"w")) == NULL )
		error("cannot open %s",outfile);

	for ( ;; ) {
	    if ( gline(&aloc,&rline) == 0 )
		error("empty input file");
	    if ( aloc < 0 )
		printf("\n");
	    else
		break;
	}
	strcpy(aline,rline);

	nblank = 0;
	while ( gline(&bloc,&rline) ) {
	    if ( bloc < 0 ) {
		++nblank;
		continue;
	    }
	    printf("0x%x:\t%04.4x\t%s",aloc,image[index++],aline);
	    for ( aloc+=2; aloc<bloc; aloc+=2 ) {
		printf("0x%x:\t%04.4x\n",aloc,image[index++]);
	    }
	    while ( nblank ) {
		printf("\n");
		--nblank;
	    }
	    aloc = bloc;
	    strcpy(aline,rline);
	}
	printf("0x%x:\t%04.4x\t%s",aloc,image[index++],aline);
	for ( aloc+=2; index<IMSIZE; aloc+=2 ) {
	    printf("0x%x:\t%04.4x\n",aloc,image[index++]);
	}
	while ( nblank-- )
	    printf("\n");
}

gline(addr,rline)
long *addr;
char **rline;
{
	static char line[MAXLINE];
	register char *p;

	if ( fgets(line,MAXLINE,adbfp) == NULL )
		return(0);
	if ( line[0] == '\n' ) {	/* preserve blank lines */
		*addr = -1;
		*rline = line;
		return(1);
	}
	sscanf(line,"0x%x",addr);
	for ( p=line; ; ) {
		if ( *p++ == ':' )
			break;
	}
	for ( ; *p=='\t'; p++ )
		;
	*rline = p;
	return(1);

}

error(f,s)
char *f, *s;
{
	fprintf(stderr,f,s);
	fprintf(stderr,"\n");
	exit(1);
}

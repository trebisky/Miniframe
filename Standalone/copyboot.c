/* copyboot.c
	stand-alone utility for the Miniframe.
	write a boot image in the first tracks of a (hard) disk.
	the disk label must have already been written.
	this utility writes the boot image immediately after the label
	then updates the label so the boot roms can find the boot image.
	tjt  4/26/91
*/
#include "../h/param.h"
#include "../h/vm.h"
#include "../machine/a.out.h"

#include "volhdr.h"
struct ctvol sblock;
#define KSIZE 1024

char line[100];

extern char end;

main()
{
	int io, dio;
	char *copyboot();
	char *last;

	printf("\nStandalone Copyboot\n");
	if ( sizeof(struct ctvol) != KSIZE )
	    _stop("Superblock structure malformed\n");

	for (;;) {
	    printf("From : ");
	    gets(line);
	    io = open(line, 0);
	    if (io >= 0) {
		last = copyboot(&end, io);
		close(io);
	    } else
		continue;

	    printf("To : ");
	    gets(line);


	    dio = open(line, 0);
	    if ( read(dio,(char *) &sblock, KSIZE) != KSIZE ) {
		printf("cannot read super block\n");
		close(dio);
		continue;
	    }
	    close(dio);

	    if ( sblock.magic !=  (long) CTMAGIC ) {
		printf("this disk partition is not labelled\n");
		continue;
	    }

	    dio = open(line, 1);
	    if (dio >= 0) {
		if ( mkboot(dio, &end, last) ) {
		    close(dio);
		    break;
		}
	    }
	    close(dio);
	}
}

char *
copyboot(addr, io)
char *addr;
register io;
{
	struct exec x;
	register int i;

	i = read(io, (char *)&x, sizeof x);
	if (i != sizeof x ||
	    (x.a_magic != 0407 && x.a_magic != 0413 && x.a_magic != 0410))
		_stop("Bad format\n");

	printf("%d", x.a_text);
	if (x.a_magic == 0413 && lseek(io, 0x400, 0) == -1)
		goto shread;
	if (read(io, addr, x.a_text) != x.a_text)
		goto shread;
	addr += x.a_text;

	/* XXX  tjt  3/2/91
	 * This depends on the value of CLSIZE set in machine/machparam.h
	 * no telling if it is set right (also see param.h).
	 */
	if (x.a_magic == 0413 || x.a_magic == 0410)
		while ((int)addr & CLOFSET)
			*addr++ = 0;

	printf("+%d", x.a_data);
	if (read(io, addr, x.a_data) != x.a_data)
		goto shread;
	addr += x.a_data;
#ifdef NEVER
/* ignore bss - it must have a startup that zeros bss */
	printf("+%d", x.a_bss);
	x.a_bss += 128*512;	/* slop */
	for (i = 0; i < x.a_bss; i++)
		*addr++ = 0;
#endif
	printf("\n");
	return (addr);
shread:
	_stop("Short read\n");
}

/* calculate checksum for disk superblock */
long
lsum (buf, nlong)
register long *buf;
register nlong;
{
	unsigned long sum = 0;

	while ( nlong-- )
		sum += *buf++;
	return ( sum );
}

/* write a bootable image on this disk.
 * The i/o for the boot image is done in 1K blocks,
 * in particular, note that the size of the volume header
 * must be a 1K unit (this is verified below).
 */

mkboot (dio, start, end)
int dio;
char *start, *end;
{
	u_long imsize;
	char *addr;
	long aseek;
	int imblocks;
	int num;

	imsize = end - start + 1;
	imblocks = (imsize+KSIZE-1) / KSIZE;

	printf("image size: %d bytes\n",imsize);
	printf("image uses %d 1K blocks\n",imblocks);
	
	sblock.ldrptr = (long) 1;
	sblock.ldrcnt = imblocks;
	sblock.cksum = (long) (-1) -
			lsum ( (long *) &sblock, (KSIZE/sizeof(long))-1 );

	lseek ( dio, (long) 0, 0 );	/* probably needless */

	if ( write(dio,(char *) &sblock, KSIZE) != KSIZE ) {
	    printf("cannot write super block\n");
	    return ( 0 );
	}

	/* It would seem tidy to zero the unused part of the last block,
	 * but in fact it is unnecessary (It will be the BSS area anyway
	 * and will get zeroed by the startup code if need be).
	 */
	aseek = (long) KSIZE;
	addr = start;
	while ( imblocks ) {
	    num = 8;
	    if ( addr == start )
		num = 7;
	    if ( imblocks < num )
		num = imblocks;
	    lseek ( dio, aseek, 0 );
	    printf("writing %d K\n",num);
	    if ( write(dio, addr, num*KSIZE) != num*KSIZE ) {
		printf("cannot write boot image\n");
		return ( 0 );
	    }
	    imblocks -= num;
	    addr += num*KSIZE;
	    aseek += (num*KSIZE + 512);	/* leave odd sector at track end */
	}
}

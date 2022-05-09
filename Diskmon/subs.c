/* subs.c - enough subroutines to get the Gnu disassembler
 * running for the stand-alone Miniframe debugger, we take
 * lots of short cuts.
 * Our "opcode.h" is from m68k-opcode.h
 * Our "pinsn.c"  is from m68k-pinsn.h
 * Our "param.h"  is from m-sun2.h
 * T. Trebisky  9/22/89
 */
#include <stdio.h>
#include "defs.h"
#include "param.h"

char *reg_names[] = REGISTER_NAMES;

/* Read "memory data" */
int
read_memory (memaddr, myaddr, len)
char *memaddr;
char *myaddr;
int len;
{
	while ( len-- )
	    *myaddr++ = *memaddr++;
	return ( 0 );
}

error(string,arg1,arg2,arg3)
char *string;
{
	puts(string);
	puts("\n");
	/* returns to highest command level in original version */
}

/* Print address ADDR symbolically on STREAM.
   First print it as a number.  Then perhaps print
   <SYMBOL + OFFSET> after the number.  */

void
print_address (addr, stream)
CORE_ADDR addr;
FILE *stream;
{
	fprintf (stream, "0x%x", addr);
}

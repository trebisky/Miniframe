/* autoconf.c
 *
 * this routine used to use badloc(addr) to see if an attempted
 * access to addr would cause a Bus error, if so badloc() would
 * return true -- this is assembly code in srt0.c
 *  tjt  3/2/91
 */
#include "../machine/hardware.h"

configure()
{
	/* initialize the PIC, this proved to be a smart thing to do */
	*PIC_A0 = ICW1;
	*PIC_A1 = ICW2;
	*PIC_A1 = ICW4;

	*PIC_A1 = 0xff;		/* all sources masked */
}


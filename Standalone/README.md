Convergent Technologies Miniframe

Standalone project

This is a "treasure box" (Pandoras box) of odds and ends,
most of which boot from floppy.

Files with a "70k" extension are images intended to be loaded and
run by the boot roms at the 0x70000 address.

This seems more like 7k to me 30 years later, but I am just copying
these files verbatim and preserving history.

Take special note of mkboot.c as it is a tool to put images onto a
floppy with the proper header and such so that the bootroms will
be satisfied.

At one point I used my old Callan machine to run mkboot and make
bootable floppies (using kermit to transfer the file to the Callan),
but notes here suggest that I later used other machines that had
working floppy drives, including a DEC Rainbow (of all things) as
well as whatever PC/AT machine I had running DOS or some early
version of Windows.  The PC/AT used something called RX50 driver,
which may have had to do with support for higher density floppies,
but not yet 1.2M (as I remember).

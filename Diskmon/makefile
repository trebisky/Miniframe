# Make executable file for Convergent Tech, Disk based debugger.
# Build this a.out file on the Sun,
# ship it to the Callan via Kermit, run mkboot on the Callan,
# and write a boot floppy which then works on the Convergent machine.

# The -N switch avoids a segment violation from ld (on the Sun)

ENTER_LOC = 0x80017a
BOOT_LOC = 70000

# OFILES = dmonstart.o dmon.o pinsn.o subs.o 
OFILES = dmonstart.o dmon.o

dmon:	$(OFILES)
	ld -N -T $(BOOT_LOC) -o dmon -s $(OFILES)

dmon.sym:		$(OFILES)
	ld -N -T $(BOOT_LOC) -o dmon.sym $(OFILES)

dmonstart.o:		dmonstart.s
	as -o dmonstart.o -m68010 dmonstart.s

dmon.o:	dmon.c
	cc -fsoft -mc68010 -DREENTER=$(ENTER_LOC) -S dmon.c
	as -o dmon.o -m68010 dmon.s

# the following is for when we add the Gnu disassembler:

pinsn.o:	pinsn.c opcode.h
	cc -c -fsoft -mc68010 pinsn.c

subs.o:	subs.c
	cc -c -fsoft -mc68010 subs.c

clean:
	rm -f dmon.sym dmon dmonstart.o dmon.o

# Make patch file for convergent tech boot roms
# The -N switch to ld avoids a segment violation from the -T option

COPTS=	-DMINIFRAME
CFLAGS=	-mc68000 ${COPTS}

# even though the Gnu document on gas says the 68010 switch is largely
# ignored, USE IT! otherwise it generates 020 opcodes, for example for
# bsr, you get bsrl, whereas with -mc68010 you get a nice jsr to go to
# an external symbol.

MCC = xgcc
MAS = xas68 -mc68010
MLD = xld
MCLIB = /u/tom/bin.sun4/gcc-xgnulib

PATCH_LOC = 0x800172
ENTER_LOC = 0x80017a
MON_LOC = 0x801000
RAM_LOC = 50000

ROM:	mkrom mon
	mkrom b $(PATCH_LOC) $(MON_LOC) mon

mkrom:	mkrom.c
	cc -o mkrom mkrom.c

mon:	mon.o cmon.o
	${MLD} -N -T $(RAM_LOC) -o mon -s mon.o cmon.o $(MCLIB)

mon.o:	mon.s
	${MAS} -o mon.o mon.s

cmon.o:	cmon.c
	${MCC} ${CFLAGS} -DREENTER=$(ENTER_LOC) -c cmon.c

cmon.s:	cmon.c
	${MCC} ${CFLAGS} -DREENTER=$(ENTER_LOC) -S cmon.c

# below here is historical, probably obsolete and not working.
# test and adb stuff below
test:	cmon.c testio.c
	cc -o test -DREENTER=0x2020 -DTEST cmon.c testio.c
	rm cmon.o

ADB:	mon.p cmon.c
	/lib/cpp -P -DTEST mon.p amon.s
	as -o amon.o -m68010 amon.s
	cc -o acmon.s -fsoft -mc68010 -S -DTEST cmon.c
	as -o acmon.o -m68010 acmon.s
	ld -dc -dp -e mon_ent -o ADB amon.o acmon.o

amon.o:	amon.s

# Just an experiment with the bsr instruction
patch:	patch.s
	as -o patch.o -m68010 patch.s
	ld -N -T 800000 -o patch -s patch.o

# ---------------------------------------------------------

all:	link bootstrap

install:	all
	cp link /u/tom/bin.sun4/link
	cp bootstrap /u/tom/bin.sun4/bootstrap

link:	link.o ttsubs.o
	$(CC) -o link link.o ttsubs.o

link.o:	link.c
	$(CC) -c link.c

ttsubs.o:	ttsubs.c
	$(CC) -traditional -c ttsubs.c

# Using optimization does bad things to hardware polling loops!!!!!!
# (the real answer is to use "volatile" and allow optimization)
# CFLAGS= -O -mc68000 ${INCPATH} ${COPTS}


CC = gcc
MCC = xgcc
MAS = xas68 -mc68010
MLD = xld
MCLIB = /u/tom/bin.sun4/gcc-xgnulib

.c.o:
	${MCC} ${CFLAGS} -c $*.c

bootstrap:	gnub
	cp gnub bootstrap

# these parameters apply only to the GDB nub
ISTACK = 6C000
NBOOT_LOC = 6C000

vecjmp.o: vecjmp.c
	$(MCC) -E ${COPTS} -DMC68010 vecjmp.c >vecjmp.s
	$(MAS) vecjmp.s -o vecjmp.o
	rm vecjmp.s

# gnub - GDB nub (the REAL thing)
gsrt0.o: gsrt0.c
	$(MCC) -E -DISTACK=0x${ISTACK} ${COPTS} -DMC68010 gsrt0.c >gsrt0.s
	$(MAS) gsrt0.s -o gsrt0.o
	rm gsrt0.s

gnub:	gnub.o gsrt0.o
	$(MLD) -N -T $(NBOOT_LOC) -o gnub gsrt0.o gnub.o $(MCLIB)
#	$(MLD) -N -T $(NBOOT_LOC) -o gnub -s gsrt0.o gnub.o $(MCLIB)
# symbol table doesn't hurt a thing - link ignores it.

# enub - echo nub (to test the concept of downloading the nub and
#		   running at 38400 baud)
# NRELOC sets the stack base (and that's all -- poorly chosen name)
NRELOC=	6C000

esrt0.o: esrt0.c
	$(MCC) -E -DRELOC=0x${NRELOC} ${COPTS} esrt0.c >esrt0.s
	$(MAS) esrt0.s -o esrt0.o
	rm esrt0.s

enub:	enub.o esrt0.o prf.o
	$(MLD) -N -T $(NBOOT_LOC) -o enub -s esrt0.o enub.o prf.o $(MCLIB)

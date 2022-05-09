#
# Copyright (c) 1980, 1986 Regents of the University of California.
# All rights reserved.  The Berkeley software License Agreement
# specifies the terms and conditions for redistribution.
#
#	@(#)Makefile	7.1 (Berkeley) 6/5/86
#
DESTDIR=/
# the -I../h is to support ../h/vm.h which includes several files
# in ../h without any prefixing path.
# INCPATH=-I. -I../h
INCPATH=-I../h

# Using optimization does bad things to hardware polling loops!!!!!!
# (the real answer is to use "volatile" and allow optimization)
# CFLAGS= -O -mc68000 ${INCPATH} ${COPTS}
CFLAGS=	-mc68000 -nostdinc ${INCPATH} ${COPTS}
COPTS=	-DMINIFRAME -DSTANDALONE
CLIBS=	$(LIBSA) $(MCLIB)

# even though the Gnu document on gas says the 68010 switch is largely
# ignored, USE IT! otherwise it generates 020 opcodes, for example for
# bsr, you get bsrl, whereas with -mc68010 you get a nice jsr to go to
# an external symbol.

MCC = xgcc
MAS = xas68 -mc68010
MLD = xld
MCLIB = /u/tom/bin.sun4/gcc-xgnulib

RELOC=	70000
BOOT_LOC = 70000

# SRCS=	sys.c conf.c prf.c machdep.c autoconf.c \
# 	drtest.c format.c atol.c string.c
SRCS=	sys.c conf.c prf.c machdep.c autoconf.c atol.c atoh.c string.c

DUMMIES= bootxx.c confxx.c
DRIVERS=autoconf.o fd.o hd.o
LIBSA=	libsa.a

ALL=	boot copy bootfd boothd

all: ${ALL}


${LIBSA}: sys.o conf.o ${DRIVERS} prf.o machdep.o atol.o atoh.o string.o
	ar crv ${LIBSA} $?
	ranlib ${LIBSA}

.c.o:
	${MCC} ${CFLAGS} -c -g $*.c

# .s.o:
# 	/lib/cpp -E $*.s | ${AS} -o $*.o
# 	-ld -x -r $*.o
# 	mv a.out $*.o

zzz.o: zzz.s
#	$(MCC) -E -DRELOC=0x${RELOC} ${COPTS} srt0.c >srt0.s
	$(MAS) zzz.s -o zzz.o

# ***** eliminated ?? for miniframe.
dkbad.o: ../vax/dkbad.c
	${MCC} -c ${CFLAGS} ../vax/dkbad.c

# startups

srt0.o: srt0.c
	$(MCC) -E -DRELOC=0x${RELOC} ${COPTS} srt0.c >srt0.s
	$(MAS) srt0.s -o srt0.o

relsrt0.o: srt0.c
	$(MCC) -E -DRELOC=0x${RELOC} -DREL ${COPTS} srt0.c >relsrt0.s
	$(MAS) relsrt0.s -o relsrt0.o

# bootable from floppy or real disks

boot:	boot.o srt0.o conf.o $(CLIBS)
	$(MLD) -N -T 0 -o boot srt0.o boot.o conf.o $(CLIBS)

boot.70k:	boot.o srt0.o conf.o $(CLIBS)
	$(MLD) -N -T ${RELOC} -o boot.70k srt0.o boot.o conf.o $(CLIBS)

copyboot:	copyboot.o srt0.o conf.o $(CLIBS)
	$(MLD) -N -T 0 -o copyboot srt0.o copyboot.o conf.o $(CLIBS)

ls:	ls.o srt0.o conf.o $(CLIBS)
	$(MLD) -N -T 0 -o ls srt0.o ls.o conf.o $(CLIBS)

cat:	cat.o srt0.o conf.o $(CLIBS)
	$(MLD) -N -T $(BOOT_LOC) -o cat srt0.o cat.o $(CLIBS)

copy:	copy.o srt0.o conf.o $(CLIBS)
	$(MLD) -N -T 0 -o copy srt0.o copy.o $(CLIBS)

copy.70k:	copy.o srt0.o conf.o $(CLIBS)
	$(MLD) -N -T $(BOOT_LOC) -o copy.70k srt0.o copy.o $(CLIBS)

#format:	format.o srt0.o conf.o $(CLIBS)
#	$(MLD) -N -o format srt0.o format.o conf.o $(CLIBS)
#
#drtest:	drtest.o srt0.o conf.o $(CLIBS)
#	$(MLD) -N -o drtest srt0.o drtest.o conf.o $(CLIBS)
#
mkfs.o:	../etc/mkfs.c
	${MCC} ${CFLAGS} -c -g ../etc/mkfs.c

mkfs:	mkfs.o srt0.o $(CLIBS)
	$(MLD) -N -T $(BOOT_LOC) -o mkfs srt0.o mkfs.o $(CLIBS)

hard.s:	hard.c
	$(MCC) ${CFLAGS} -S -o hard.s hard.c

hard:	hard.o srt0.o $(CLIBS)
	$(MLD) -N -T 0 -o hard srt0.o hard.o $(CLIBS)

hard.70k:	hard.o srt0.o $(CLIBS)
	$(MLD) -N -T $(BOOT_LOC) -o hard.70k srt0.o hard.o $(CLIBS)

floppy:	floppy.o srt0.o $(CLIBS)
	$(MLD) -N -T 0 -o floppy srt0.o floppy.o $(CLIBS)

# these parameters apply only to the GDB nub
# NRELOC sets the stack base (and that's all -- poorly chosen name)
NRELOC=	6C000
NBOOT_LOC = 6C000

nsrt0.o: nsrt0.c
	$(MCC) -E -DRELOC=0x${NRELOC} ${COPTS} nsrt0.c >nsrt0.s
	$(MAS) nsrt0.s -o nsrt0.o
	rm nsrt0.s

nub:	nub.o nsrt0.o $(CLIBS)
	$(MLD) -N -T $(NBOOT_LOC) -o nub -s nsrt0.o nub.o $(CLIBS)

echo:	echo.o srt0.o $(CLIBS)
	$(MLD) -N -T $(BOOT_LOC) -o echo -s srt0.o echo.o $(CLIBS)

echo.sym:	echo.o srt0.o $(CLIBS)
	$(MLD) -N -T $(BOOT_LOC) -o echo.sym srt0.o echo.o $(CLIBS)

# bootstrap from ether

### not yet, rosin, not yet ###

# getting booted from disc

bootfd: relsrt0.o bootfd.o conffd.o smsys.o $(CLIBS)
	$(MLD) -N -T ${RELOC} relsrt0.o bootfd.o conffd.o smsys.o $(CLIBS)
	strip a.out;dd if=a.out of=bootfd ibs=32 skip=1;rm -f a.out

boothd: relsrt0.o boothd.o confhd.o smsys.o $(CLIBS)
	$(MLD) -N -T ${RELOC} relsrt0.o boothd.o confhd.o smsys.o $(CLIBS)
	strip a.out;dd if=a.out of=boothd ibs=32 skip=1;rm -f a.out

bootfd.o: bootfd.c bootxx.o
boothd.o: boothd.c bootxx.o
 
bootxx.o:
	touch bootxx.o

# the -sun3 switch is provided on all the other cc -c lines, we need to
# explicitly provide it here, or cc generates calls to lmodt, ldivt, and lmult.
# which doubtless are to be found in the -sun2 libraries, we could be in deep
# trouble if the later -sun3 switch is overriding the earlier -mc68010 switch.
# tjt  3/10/90

smsys.o: sys.o
	-rm -f smsys.c
	-ln -s sys.c smsys.c
	$(MCC) -c -DSMALL ${CFLAGS} smsys.c
	-rm -f smsys.c

bootfd.c: bootxx.c
	-rm -f bootfd.c
	sed -e 's/xx/fd/g' <bootxx.c >bootfd.c

boothd.c: bootxx.c
	-rm -f boothd.c
	sed -e 's/xx/hd/g' <bootxx.c >boothd.c

conffd.o: conffd.c confxx.o
confhd.o: confhd.c confxx.o

confxx.o:
	touch confxx.o

conffd.c: confxx.c
	-rm -f conffd.c
	sed -e 's/XX/fd/' -e 's/xx/fd/g' <confxx.c >conffd.c
confhd.c: confxx.c
	-rm -f confhd.c
	sed -e 's/XX/hd/' -e 's/xx/hd/g' <confxx.c >confhd.c

# utilities

print:
	@pr makefile
	@ls -l | pr 
	@pr *.h *.c

clean:
	rm -f *.o *.exe *.i errs
	rm -f a.out boot cat copy
	rm -f boot[a-z]? boot[a-wyz][a-z].c conf[a-wyz][a-z].c
	rm -f format core sboot

lint:
	lint ${COPTS} -hxbn boot.c ${SRCS} | \
	    grep -v 'possible pointer alignment' | \
	    grep -v 'struct/union .* never defined'

install: ${ALL}
	cp boot ${DESTDIR}/boot
	cp format ${DESTDIR}/format
	cp copy ${DESTDIR}/copy
	cp drtest ${DESTDIR}/drtest
	strip ${DESTDIR}/format ${DESTDIR}/copy ${DESTDIR}/drtest
	cp boot a.out; strip a.out; \
		dd if=a.out of=../floppy/boot bs=32 skip=1; rm a.out
	cp copy a.out; strip a.out; \
		dd if=a.out of=../floppy/copy bs=32 skip=1; rm a.out
	cp format a.out; strip a.out; \
		dd if=a.out of=../floppy/format bs=32 skip=1; rm a.out
	cp drtest a.out; strip a.out; \
		dd if=a.out of=../floppy/drtest bs=32 skip=1; rm a.out

# /usr/mdec is where boot blocks live to be picked up by newfs.
	cp bootfd boothd ${DESTDIR}/usr/mdec

depend:
	for i in ${SRCS} ${DUMMIES}; do \
	    $(MCC) -M -DSTANDALONE ${INCPATH} $$i | \
	    awk ' { if ($$1 != prev) { print rec; rec = $$0; prev = $$1; } \
		else { if (length(rec $$2) > 78) { print rec; rec = $$0; } \
		else rec = rec " " $$2 } } \
		END { print rec } ' >> makedep; done
	echo '/^# DO NOT DELETE THIS LINE/+2,$$d' >eddep
	echo '$$r makedep' >>eddep
	echo 'w' >>eddep
	cp Makefile Makefile.bak
	ed - Makefile < eddep
	rm eddep makedep
	echo '# DEPENDENCIES MUST END AT END OF FILE' >> Makefile
	echo '# IF YOU PUT STUFF HERE IT WILL GO AWAY' >> Makefile
	echo '# see make depend above' >> Makefile

# DO NOT DELETE THIS LINE -- make depend uses it

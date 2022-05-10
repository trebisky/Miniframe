# Makefile for Miniframe mkboot

mkboot:	mkboot.c
	cc -o mkboot mkboot.c

test:	dmon.img

dmon.img:	dmon FORCE
	./mkboot dmon dmon.img

FORCE:

get:
	cp ../Diskmon/dmon .

clean:
	rm -f mkboot

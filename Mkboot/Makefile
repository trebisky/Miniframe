# Makefile for Miniframe mkboot

mkboot:	mkboot.c
	cc -o mkboot mkboot.c

test:	dmon.img

dmon.img:	dmon
	./mkboot dmon dmon.img

get:
	cp ../Diskmon/dmon .

clean:
	rm -f mkboot

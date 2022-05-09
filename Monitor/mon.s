/*
 Modified 12/26/90 to be palatable to gas (xas68k)
 Assembly language startup file for the
 Miniframe boot rom monitor.
 This code is added to the standard Miniframe boot rom's
 at a link-time defined address (see the makefile).

 T. Trebisky  8/28/89

 ROM_BASE will never change, for this machine.
 The next numbers are crucial - must match values used elsewhere
   ROM_OFFSET must match the way the roms were patched/burned.
   ROM_COUNT could be defined in terms of ROM_OFFSET, but we just
    grind it out by hand and stick it here, it is the count of
    4 byte pieces (minus 1 for the dbra) that get moved.
    For the pair of 2764's we are using this is:
    (0x4000-ROM_OFFSET)/4 - 1
*/

ROM_BASE = 0x800000

ROM_OFFSET = 0x1000
ROM_COUNT = 0xbff

VEC_BASE = 0x40000	| put a table of vectors here

GCRADDR = 0x450000	| includes LED's
LEDON  =  0x3000	| all 4 LED are on
LEDOF  =  0x3f00	| all 4 LED are off

|  This code first fires up in ROM at the entry point below
|    (at address ROM_BASE+ROM_OFFSET), it makes a copy of itself
|    in RAM (at whatever address it is linked to run at) which it
|    then jumps into to run.  The code must be position independent
|    up to the point where it jumps into the RAM copy.

| This first entry point is entered only on system reset

	.text
	.globl	mon_ent
	.globl	_cdelay
mon_ent:	
	clrw	sp@-		| leave 2 bytes of space
	movl	sp@(2),sp@	| move the copy of PC
	clrw	sp@(4)		| phony VEC for RTE
	movw	sr,sp@-		| for RTE
	pea	sp@(8)		| where the sp really was
	moveml	d0-d7/a0-a6,sp@-

	movl	#mon_ent,a0	| where this should go in RAM
	movl	#ROM_BASE+ROM_OFFSET,a1	| where it is now
	movl	#ROM_COUNT,d1	| see big comment at start of file
rloop:	movl	a1@+,a0@+	| 4 bytes at a time
	dbra	d1,rloop
	jmp	rament:l	| into the RAM copy

rament:
	bsr	hinit		| hardware initialization hook
	movw	#0x3100,GCRADDR
	pea	sp@		| pointer to "C structure"
	bsr	_cmon		| enter C initialization
	addql	#4,sp
	moveml	sp@+,d0-d7/a0-a6
	addql	#4,sp		| don't restore sp
	rte			| restores sr, pc, cleans stack

utrap:	
	pea	sp@(8)		| where the sp really was
	moveml	d0-d7/a0-a6,sp@-
	pea	sp@
	bsr	_cutrap		| enter C handler
	addql	#4,sp
	moveml	sp@+,d0-d7/a0-a6
	addql	#4,sp		| don't restore sp
	rte

ttrap:	
	pea	sp@(8)		| where the sp really was
	moveml	d0-d7/a0-a6,sp@-
	pea	sp@
	bsr	_cttrap		| enter C handler
	addql	#4,sp
	moveml	sp@+,d0-d7/a0-a6
	addql	#4,sp		| don't restore sp
	rte

| hardware initialization:

| set up vector table and interrupt handlers

hinit:
	movl	#VEC_BASE,a1	| we put the vector table here
	movec	a1,vbr
	lea	utrap,a0
	movl	#0xff,d1

iloop:	movl	a0,a1@+		| everyone points here
	dbra	d1,iloop

	lea	ttrap,a0
	movec	vbr,a1
	movl	a0,a1@(0x24)	| trace exception vector

| blink lights  (fun)
		
|	movl	#3,d3		| blink 4 times
|blink:	movw	#LEDOF,GCRADDR
|	bsr	delay
|	movw	#LEDON,GCRADDR
|	bsr	delay
|	dbra	d3,blink

	rts		| end of hinit

| little delay loop (should be .5 sec executed from RAM)
| remember, dbra works on a word (16 bits) only

DCOUNT1 =  112		| delay count
DCOUNT2 =  2000		| delay count

| C entry point

_cdelay:
	movl	d1,sp@-
	movl	d2,sp@-
	bsr	delay
	movl	sp@+,d2
	movl	sp@+,d1
	rts

delay:
	movl	#DCOUNT1,d2
ld1:	movl	#DCOUNT2,d1
ld2:	dbra	d1,ld2
	dbra	d2,ld1
	rts

#
# Assembly language startup file for the
# Miniframe DISK debug monitor.
#
# T. Trebisky  9/21/89
#

VEC_BASE = 0x40000	| put a table of vectors here

GCRADDR = 0x450000	| includes LED's


# This first entry point is entered only on system reset

	.text
	.globl	start
	.globl	_cdelay
	.globl	_callrom
start:	
	clrw	sp@-		| leave 2 bytes of space
	movl	sp@(2),sp@	| move the copy of PC
	clrw	sp@(4)		| phony VEC for RTE
	movw	sr,sp@-		| for RTE
	pea	sp@(8)		| where the sp really was
	moveml	d0-d7/a0-a6,sp@-

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

# hardware initialization:

# set up vector table and interrupt handlers

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

	rts		| end of hinit

# this hook is used so the monitor C code can "call" the ROM
# call via:  callrom(&romregs);
# where:	struct mregs romregs;	has been declared

_callrom:
	moveml	d0-d7/a0-a6,sp@-	| save our registers
	pea	romret			| where ROM's rts returns to
	movl	sp@(68),a0		| pointer to mregs structure
	movl	a0@(68),sp@-		| PCL & VEC for RTE
	movl	a0@(64),sp@-		| SR & PCH for RTE
	moveml	a0@,d0-d7/a0-a6		| his registers
	rte				| gone to ROM-land
#
# ROM routine *MUST* return via rts with stack intact
#
romret:
	movl	a0,sp@-			| clumsy - need a register
	movl	sp@(68),a0		| pointer to mregs structure
	moveml	d0-d7/a0-a6,a0@		| save his registers
	lea	a0@(32),a1		| where we want a0 put
	movl	sp@+,a1@		| there it is
	moveml	sp@+,d0-d7/a0-a6	| restore our registers
	rts

# little delay loop (should be .5 sec executed from RAM)
# remember, dbra works on a word (16 bits) only

DCOUNT1 =  112		| delay count
DCOUNT2 =  2000		| delay count

# C entry point

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

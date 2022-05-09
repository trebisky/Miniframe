# 1 "srt0.c"
|
| Assembly language startup file for the
| Miniframe standalone utilities.	(srt0.c)
|
| T. Trebisky  2/7/90
|

VEC_BASE = 0x0		| put the table of vectors here

	.globl	entry
	.globl	__rtt
	.globl	_badloc

	.globl	_end, _edata
	.globl	_configure
	.globl	_main

	.text
entry:	
| cannot trace/single step if we monkey with interrupt system.
	movw	#0x2700,sr	| Supervisor, interrupts off
	movl	#0x70000 ,sp	| Stack grows down










start:
	movl	#_edata,a1	| start of BSS
	movl	#_end,a2	| end of BSS
clr:	clrb	a1@+		| zero a byte
	cmpl	a1,a2		| done ?
	bne	clr

	bsr	_configure	| enter autoconf.c
	bsr	_main		| main entry point in sys.c
	bra	start

__rtt:
	bra	start		| could just die here till reset ?


| badloc(address);
| used in autoconf.c to probe addresses and
| see if a bus error pops up.

_badloc:
	 
	rts

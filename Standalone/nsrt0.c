|
| Assembly language startup file for the
| Miniframe gdb nub. 		(nsrt0.c)
|
| T. Trebisky  12/3/90
|

VEC_BASE = 0x0		| put the table of vectors here.
GCR = 0x450000		| be sure NMI are disabled.

	.text
	.globl	entry
	.globl	__rtt

	.globl	_configure
	.globl	_main

entry:	
	movw	#0x2700,sr	| Supervisor, interrupts off
	movl	#VEC_BASE,a1	| we put the vector table here
	movec	a1,vbr
	movw	#0x3000,GCR
	movl	#RELOC,sp	| Stack grows down
start:
	bsr	_configure	| enter autoconf.c
	bsr	_main		| main entry point in sys.c
	bra	start

__rtt:
	bra	start		| could just die here till reset ?

# patch to the Miniframe boot rom
# the aim is to jump into my own monitor at the end of ROM
# T. Trebisky  8/28/89
#

GCRADDR = 0x450000	| includes LED's
LEDON  =  0x3000	| all 4 LED are on
LEDOF  =  0x3f00	| all 4 LED are off
DCOUNT =  1000000	| delay count

	.text
. = 0x172
	
PATCH:	bsr 	mymon
	movw	#0x3700,0x450000
	clrl	d3

. = 0x1000
mymon:	movw	#0x3700,0x450000

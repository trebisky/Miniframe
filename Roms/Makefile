# makefile

all:
	converg
	tail +33c conv.out >conv.bin
	od -x conv.bin +0x0 0x800000 >conv.dmp

converg:	converg.c
	cc -o converg converg.c

#conv.dis:	conv.out
#	adb conv.out - >conv.dis
#	800000,-1?ia
#	$q

#NO_APP
gcc_compiled.:
.text
LC0:
	.ascii "\12"
	.ascii "68010 Miniframe monitor 8/30/89\12\0"
	.even
.globl _cmon
_cmon:
	link a6,#0
	movel a2,sp@-
	movel a6@(8),a2
	movew #12800,4521984
	movel #8388986,a2@(66)
	jbsr _hwinit
	pea LC0
	jbsr _puts
	clrw _autot
	clrw _tcount
	clrw _nbkp
	clrl _nextadr
	movel a2,sp@-
	jbsr _user
L1:
	movel a6@(-4),a2
	unlk a6
	rts
LC1:
	.ascii "Exception vector \0"
LC2:
	.ascii " at address \0"
	.even
.globl _cutrap
_cutrap:
	link a6,#-4
	movel a2,sp@-
	movel a6@(8),a2
	movew #16128,4521984
	movew a2@(70),d1
	andw #4095,d1
	movew d1,a6@(-2)
	pea LC1
	jbsr _puts
	pea 2:w
	movel a6,d0
	subql #2,d0
	movel d0,sp@-
	jbsr _puth
	pea LC2
	jbsr _puts
	pea 4:w
	moveq #66,d0
	addl a2,d0
	movel d0,sp@-
	jbsr _puth
	pea 10:w
	jbsr _putc
	movel a2,sp@-
	jbsr _user
L2:
	movel a6@(-8),a2
	unlk a6
	rts
LC3:
	.ascii "Trace: \0"
	.even
.globl _cttrap
_cttrap:
	link a6,#0
	movel a2,sp@-
	movel a6@(8),a2
	movew #16128,4521984
	jbsr _chkc
	movel d0,d0
	tstl d0
	jeq L4
	movel a2,sp@-
	jbsr _user
	addqw #4,sp
L4:
	tstw _nbkp
	jeq L5
	subqw #1,_maxbk
	tstw _maxbk
	jeq L5
	movel a2@(66),d1
	cmpl _bkadr:l,d1
	jeq L5
	jra L3
L5:
	pea LC3
	jbsr _puts
	pea 4:w
	moveq #66,d0
	addl a2,d0
	movel d0,sp@-
	jbsr _puth
	pea 32:w
	jbsr _putc
	pea 16:w
	movel a2@(66),sp@-
	jbsr _puth
	pea 10:w
	jbsr _putc
	addw #28,sp
	tstw _tcount
	jeq L6
	subqw #1,_tcount
	tstw _tcount
	jeq L6
	jra L3
L6:
	movel a2,sp@-
	jbsr _user
L3:
	movel a6@(-4),a2
	unlk a6
	rts
LC4:
	.ascii "TMON> \0"
LC5:
	.ascii "must give start and stop address\12\0"
LC6:
	.ascii "Breakpoint cleared\12\0"
LC7:
	.ascii "?unknown\12\0"
	.even
.globl _user
_user:
	link a6,#-20
	moveml #0x3020,sp@-
	movel a6@(8),d2
	movew #15616,4521984
	movel d2,a0
	andw #32767,a0@(64)
	movel d2,sp@-
	jbsr _rdump
	addqw #4,sp
L8:
	pea LC4
	jbsr _puts
	jbsr _gets
	movel d0,a6@(-4)
	clrl sp@-
	movel a6,d0
	subql #8,d0
	movel d0,sp@-
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	jbsr _getArg
	movel d0,d0
	addw #16,sp
	moveq #-1,d1
	cmpl d0,d1
	jne L11
	tstw _autot
	jeq L12
	movel d2,a0
	orw #-32768,a0@(64)
	jra L7
L12:
	jra L10
L11:
	movel a6@(-8),d0
	moveq #100,d1
	cmpl d0,d1
	jeq L30
	moveq #100,d1
	cmpl d0,d1
	jlt L42
	moveq #1,d1
	cmpl d0,d1
	jgt L40
	moveq #3,d1
	cmpl d0,d1
	jge L31
	moveq #6,d1
	cmpl d0,d1
	jlt L40
	moveq #4,d1
	cmpl d0,d1
	jle L36
	jra L40
L42:
	moveq #114,d1
	cmpl d0,d1
	jeq L16
	moveq #114,d1
	cmpl d0,d1
	jlt L43
	moveq #102,d1
	cmpl d0,d1
	jeq L19
	moveq #103,d1
	cmpl d0,d1
	jeq L14
	jra L40
L43:
	moveq #116,d1
	cmpl d0,d1
	jeq L17
	moveq #120,d1
	cmpl d0,d1
	jeq L26
	jra L40
L14:
	pea 1:w
	moveq #66,d0
	addl d2,d0
	movel d0,sp@-
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	jbsr _getArg
	addw #12,sp
	tstw _nbkp
	jeq L15
	movel d2,a0
	orw #-32768,a0@(64)
	movew #50000,_maxbk
L15:
	jra L7
L16:
	movel d2,sp@-
	jbsr _rdump
	addqw #4,sp
	jra L13
L17:
	clrl a6@(-20)
	pea 1:w
	moveq #-20,d0
	addl a6,d0
	movel d0,sp@-
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	jbsr _getArg
	movew a6@(-18),_tcount
	addqw #1,_autot
	movel d2,a0
	orw #-32768,a0@(64)
	addw #12,sp
	tstw _nbkp
	jeq L18
	movew #1,_maxbk
L18:
	jra L7
L19:
	pea 1:w
	moveq #-12,d0
	addl a6,d0
	movel d0,sp@-
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	jbsr _getArg
	movel d0,d0
	addw #12,sp
	moveq #-1,d1
	cmpl d0,d1
	jne L20
	pea LC5
	jbsr _puts
	addqw #4,sp
L20:
	pea 1:w
	moveq #-16,d0
	addl a6,d0
	movel d0,sp@-
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	jbsr _getArg
	movel d0,d0
	addw #12,sp
	moveq #-1,d1
	cmpl d0,d1
	jne L21
	pea LC5
	jbsr _puts
	addqw #4,sp
L21:
	pea 1:w
	moveq #-20,d0
	addl a6,d0
	movel d0,sp@-
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	jbsr _getArg
	movel d0,d0
	addw #12,sp
	moveq #-1,d1
	cmpl d0,d1
	jne L22
	clrl a6@(-20)
L22:
	movel a6@(-20),d3
	movel a6@(-12),a2
L23:
	cmpl a6@(-16),a2
	jhi L24
	moveb d3,a2@
L25:
	addqw #1,a2
	jra L23
L24:
	jra L13
L26:
	pea 1:w
	pea _bkadr
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	jbsr _getArg
	movel d0,d0
	addw #12,sp
	moveq #-1,d1
	cmpl d0,d1
	jne L27
	tstw _nbkp
	jeq L28
	pea LC6
	jbsr _puts
	clrw _nbkp
	addqw #4,sp
L28:
	jra L29
L27:
	addqw #1,_nbkp
L29:
	jra L13
L30:
L31:
L32:
L33:
	pea 1:w
	moveq #-12,d0
	addl a6,d0
	movel d0,sp@-
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	jbsr _getArg
	movel d0,d0
	addw #12,sp
	moveq #-1,d1
	cmpl d0,d1
	jne L34
	movel _nextadr,a6@(-12)
L34:
	pea 1:w
	moveq #-16,d0
	addl a6,d0
	movel d0,sp@-
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	jbsr _getArg
	movel d0,d0
	addw #12,sp
	moveq #-1,d1
	cmpl d0,d1
	jne L35
	movel a6@(-12),d1
	addl #255,d1
	movel d1,a6@(-16)
L35:
	movel a6@(-8),sp@-
	movel a6@(-16),sp@-
	movel a6@(-12),sp@-
	jbsr _dump
	movel a6@(-16),d1
	addql #1,d1
	movel d1,_nextadr
	addw #12,sp
	jra L13
L36:
L37:
L38:
	pea 1:w
	moveq #-12,d0
	addl a6,d0
	movel d0,sp@-
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	jbsr _getArg
	movel d0,d0
	addw #12,sp
	moveq #-1,d1
	cmpl d0,d1
	jne L39
	movel _nextadr,a6@(-12)
L39:
	movel a6@(-8),sp@-
	movel a6@(-12),sp@-
	jbsr _modify
	addqw #8,sp
	jra L13
L40:
	pea LC7
	jbsr _puts
	addqw #4,sp
	jra L13
L13:
	clrw _autot
L10:
	jra L8
L9:
L7:
	moveml a6@(-32),#0x40c
	unlk a6
	rts
	.even
.globl _skipSp
_skipSp:
	link a6,#0
	movel a6@(8),a0
L45:
	movel a0@,a1
	cmpb #32,a1@
	jne L46
	addql #1,a0@
	jra L45
L46:
L44:
	unlk a6
	rts
	.even
.globl _getArg
_getArg:
	link a6,#0
	movel a2,sp@-
	movel a6@(8),a2
	movel a2,sp@-
	jbsr _skipSp
	movel a2@,a0
	addqw #4,sp
	tstb a0@
	jne L48
	moveq #-1,d0
	jra L47
L48:
	tstl a6@(16)
	jne L49
	movel a2@,a0
	cmpb #100,a0@
	jne L50
	addql #1,a2@
	movel a2@,a0
	cmpb #98,a0@
	jne L51
	movel a6@(12),a0
	moveq #1,d1
	movel d1,a0@
	jra L52
L51:
	movel a2@,a0
	cmpb #119,a0@
	jne L53
	movel a6@(12),a0
	moveq #2,d1
	movel d1,a0@
	jra L54
L53:
	movel a2@,a0
	cmpb #108,a0@
	jne L55
	movel a6@(12),a0
	moveq #3,d1
	movel d1,a0@
	jra L56
L55:
	movel a6@(12),a0
	moveq #100,d1
	movel d1,a0@
L56:
L54:
L52:
	jra L57
L50:
	movel a2@,a0
	cmpb #109,a0@
	jne L58
	addql #1,a2@
	movel a2@,a0
	cmpb #98,a0@
	jne L59
	movel a6@(12),a0
	moveq #4,d1
	movel d1,a0@
	jra L60
L59:
	movel a2@,a0
	cmpb #119,a0@
	jne L61
	movel a6@(12),a0
	moveq #5,d1
	movel d1,a0@
	jra L62
L61:
	movel a2@,a0
	cmpb #108,a0@
	jne L63
	movel a6@(12),a0
	moveq #6,d1
	movel d1,a0@
	jra L64
L63:
	movel a6@(12),a0
	moveq #109,d1
	movel d1,a0@
L64:
L62:
L60:
	jra L65
L58:
	movel a6@(12),a0
	movel a2@,a1
	moveb a1@,d0
	extw d0
	extl d0
	movel d0,d1
	andl #255,d1
	movel d1,a0@
L65:
L57:
	jra L66
L49:
	movel a2@,sp@-
	jbsr _getaddr
	movel d0,d0
	movel a6@(12),a0
	movel d0,a0@
	addqw #4,sp
L66:
L67:
	movel a2@,a0
	tstb a0@
	jeq L68
	movel a2@,a0
	cmpb #32,a0@
	jeq L68
	addql #1,a2@
	jra L67
L68:
	clrl d0
	jra L47
L47:
	movel a6@(-4),a2
	unlk a6
	rts
	.even
.globl _getaddr
_getaddr:
	link a6,#0
	movel d2,sp@-
	movel a6@(8),a0
	clrl d2
L70:
	tstb a0@
	jeq L71
	cmpb #32,a0@
	jne L71
	addqw #1,a0
	jra L70
L71:
L72:
	moveb a0@,d1
	addqw #1,a0
	tstb d1
	jeq L73
	cmpb #47,d1
	jls L74
	cmpb #57,d1
	jhi L74
	addb #208,d1
	jra L75
L74:
	cmpb #96,d1
	jls L76
	cmpb #102,d1
	jhi L76
	addb #169,d1
	jra L77
L76:
	jra L73
L77:
L75:
	asll #4,d2
	clrl d0
	moveb d1,d0
	orl d0,d2
	jra L72
L73:
	movel d2,d0
	jra L69
L69:
	movel a6@(-4),d2
	unlk a6
	rts
LC8:
	.ascii "  \0"
	.even
.globl _dump
_dump:
	link a6,#0
	moveml #0x3e00,sp@-
	moveq #1,d1
	cmpl a6@(16),d1
	jne L79
	moveq #1,d4
	jra L80
L79:
	moveq #2,d1
	cmpl a6@(16),d1
	jne L81
	moveq #2,d4
	jra L82
L81:
	moveq #3,d1
	cmpl a6@(16),d1
	jne L83
	moveq #4,d4
	jra L84
L83:
	movel a6@(12),d2
	subl a6@(8),d2
	addql #1,d2
L85:
	tstl d2
	jeq L86
	moveq #16,d1
	cmpl d2,d1
	jge L88
	moveq #16,d3
	jra L89
L88:
	movel d2,d3
L89:
	pea 4:w
	movel a6,d0
	addql #8,d0
	movel d0,sp@-
	jbsr _puth
	pea LC8
	jbsr _puts
	movel d3,sp@-
	movel a6@(8),sp@-
	jbsr _puth
	pea 10:w
	jbsr _putc
	addl d3,a6@(8)
	addw #24,sp
L87:
	subl d3,d2
	jra L85
L86:
	jra L78
L84:
L82:
L80:
	movel a6@(12),d2
	subl a6@(8),d2
	addql #1,d2
L90:
	tstl d2
	jeq L91
	pea 4:w
	movel a6,d0
	addql #8,d0
	movel d0,sp@-
	jbsr _puth
	pea LC8
	jbsr _puts
	addw #12,sp
	moveq #16,d1
	cmpl d2,d1
	jge L93
	moveq #16,d3
	jra L94
L93:
	movel d2,d3
L94:
	movel d3,d5
L95:
	tstl d5
	jeq L96
	cmpl d5,d4
	jle L98
	movel d5,d6
	jra L99
L98:
	movel d4,d6
L99:
	movel d6,sp@-
	movel a6@(8),sp@-
	jbsr _puth
	addl d6,a6@(8)
	pea 32:w
	jbsr _putc
	addw #12,sp
L97:
	subl d6,d5
	jra L95
L96:
	pea 10:w
	jbsr _putc
	addqw #4,sp
L92:
	subl d3,d2
	jra L90
L91:
L78:
	moveml a6@(-20),#0x7c
	unlk a6
	rts
	.even
.globl _modify
_modify:
	link a6,#-8
	moveq #4,d1
	cmpl a6@(12),d1
	jne L101
	moveq #1,d1
	movel d1,a6@(-4)
	jra L102
L101:
	moveq #6,d1
	cmpl a6@(12),d1
	jne L103
	moveq #4,d1
	movel d1,a6@(-4)
	moveq #-4,d1
	andl d1,a6@(8)
	jra L104
L103:
	moveq #2,d1
	movel d1,a6@(-4)
	moveq #-2,d1
	andl d1,a6@(8)
L104:
L102:
	movel a6@(8),a6@(-8)
L105:
	pea 4:w
	movel a6,d0
	subql #8,d0
	movel d0,sp@-
	jbsr _puth
	pea LC8
	jbsr _puts
	movel a6@(-4),sp@-
	movel a6@(-8),sp@-
	jbsr _puth
	pea 32:w
	jbsr _putc
	movel a6@(-4),sp@-
	movel a6@(-8),sp@-
	jbsr _getVal
	movel d0,d0
	addw #32,sp
	tstl d0
	jeq L108
	jra L106
L108:
L107:
	movel a6@(-4),d1
	addl d1,a6@(-8)
	jra L105
L106:
L100:
	unlk a6
	rts
	.even
.globl _getVal
_getVal:
	link a6,#-8
	jbsr _gets
	movel d0,a6@(-8)
	movel a6,d0
	subql #8,d0
	movel d0,sp@-
	jbsr _skipSp
	movel a6@(-8),a0
	addqw #4,sp
	cmpb #46,a0@
	jne L110
	moveq #1,d0
	jra L109
L110:
	pea 1:w
	movel a6,d0
	subql #4,d0
	movel d0,sp@-
	movel a6,d0
	subql #8,d0
	movel d0,sp@-
	jbsr _getArg
	movel d0,d0
	addw #12,sp
	moveq #-1,d1
	cmpl d0,d1
	jne L111
	clrl d0
	jra L109
L111:
	moveq #1,d1
	cmpl a6@(12),d1
	jne L112
	movel a6@(8),a0
	moveb a6@(-1),a0@
	jra L113
L112:
	moveq #4,d1
	cmpl a6@(12),d1
	jne L114
	movel a6@(8),a0
	movel a6@(-4),a0@
	jra L115
L114:
	movel a6@(8),a0
	movew a6@(-2),a0@
L115:
L113:
	clrl d0
	jra L109
L109:
	unlk a6
	rts
LC9:
	.ascii "   sr: \0"
	.even
.globl _rdump
_rdump:
	link a6,#0
	moveml #0x3f00,sp@-
	movel a6@(8),d2
	movew #15872,4521984
	movel d2,d4
	moveq #16,d5
	addl d2,d5
	moveq #32,d6
	addl d2,d6
	moveq #48,d7
	addl d2,d7
	clrl d3
L117:
	moveq #3,d1
	cmpl d3,d1
	jlt L118
	movel d4,d0
	addql #4,d4
	movel d0,sp@-
	moveq #48,d0
	addl d3,d0
	movel d0,sp@-
	pea 100:w
	jbsr _regout
	movel d5,d0
	addql #4,d5
	movel d0,sp@-
	moveq #52,d0
	addl d3,d0
	movel d0,sp@-
	pea 100:w
	jbsr _regout
	movel d6,d0
	addql #4,d6
	movel d0,sp@-
	moveq #48,d0
	addl d3,d0
	movel d0,sp@-
	pea 97:w
	jbsr _regout
	addw #36,sp
	movel d7,d0
	addql #4,d7
	movel d0,sp@-
	moveq #52,d0
	addl d3,d0
	movel d0,sp@-
	pea 97:w
	jbsr _regout
	pea 10:w
	jbsr _putc
	addw #16,sp
L119:
	addql #1,d3
	jra L117
L118:
	moveq #66,d0
	addl d2,d0
	movel d0,sp@-
	pea 99:w
	pea 112:w
	jbsr _regout
	pea LC9
	jbsr _puts
	pea 2:w
	moveq #64,d0
	addl d2,d0
	movel d0,sp@-
	jbsr _puth
	pea 10:w
	jbsr _putc
L116:
	moveml a6@(-24),#0xfc
	unlk a6
	rts
LC10:
	.ascii "   \0"
LC11:
	.ascii ": \0"
	.even
.globl _regout
_regout:
	link a6,#0
	pea LC10
	jbsr _puts
	movel a6@(8),sp@-
	jbsr _putc
	movel a6@(12),sp@-
	jbsr _putc
	pea LC11
	jbsr _puts
	pea 4:w
	movel a6@(16),sp@-
	jbsr _puth
L120:
	unlk a6
	rts
	.even
.globl _hwinit
_hwinit:
	link a6,#0
	movew #13056,4521984
	pea 8:w
	clrl sp@-
	jbsr _sbaud
	pea 8:w
	pea 1:w
	jbsr _sbaud
	jbsr _cini
L121:
	unlk a6
	rts
	.even
.globl _cini
_cini:
	link a6,#0
	movew #13312,4521984
	clrw 12779532
	clrw 12779528
	movew #24,12779524
	movew #24,12779524
	movew #2,12779524
	clrw 12779524
	movew #4,12779524
	movew #68,12779524
	movew #3,12779524
	movew #193,12779524
	movew #5,12779524
	movew #234,12779524
	movew #1,12779524
	clrw 12779524
L122:
	unlk a6
	rts
	.even
.globl _nop
_nop:
	link a6,#0
L123:
	unlk a6
	rts
	.even
.globl _sbaud
_sbaud:
	link a6,#0
	movew #13568,4521984
	tstl a6@(8)
	jne L125
	movew #54,12845062
	jbsr _nop
	movew a6@(14),d0
	movew d0,d1
	andw #255,d1
	movew d1,12845056
	jbsr _nop
	movel a6@(12),d0
	asrl #8,d0
	movew d0,12845056
	jra L126
L125:
	movew #118,12845062
	jbsr _nop
	movew a6@(14),d0
	movew d0,d1
	andw #255,d1
	movew d1,12845058
	jbsr _nop
	movel a6@(12),d0
	asrl #8,d0
	movew d0,12845058
L126:
L124:
	unlk a6
	rts
.lcomm _buf.0,128
	.even
.globl _gets
_gets:
	link a6,#0
	moveml #0x2020,sp@-
	lea _buf.0,a2
	movew #13824,4521984
L128:
	jbsr _getc
	movel d0,d0
	moveb d0,d2
	cmpb #10,d2
	jeq L129
	cmpb #64,d2
	jls L130
	cmpb #90,d2
	jhi L130
	addb #32,d2
L130:
	moveq #127,d0
	addl #_buf.0,d0
	cmpl a2,d0
	jls L131
	moveb d2,d0
	moveb d0,a2@
	addqw #1,a2
L131:
	jra L128
L129:
	clrb a2@
	movel #_buf.0,d0
	jra L127
L127:
	moveml a6@(-8),#0x404
	unlk a6
	rts
	.even
.globl _chkc
_chkc:
	link a6,#0
	movel a2,sp@-
	movew 12779524,d0
	andw #1,d0
	tstw d0
	jne L133
	clrl d0
	jra L132
L133:
	movew 12779520,d0
	andw #127,d0
	movew d0,a2
	jbsr _chkc
	moveq #1,d0
	jra L132
L132:
	movel a6@(-4),a2
	unlk a6
	rts
	.even
.globl _getc
_getc:
	link a6,#0
	movel a2,sp@-
	movew #14080,4521984
L135:
	movew 12779524,d0
	andw #1,d0
	tstw d0
	jne L136
	jra L135
L136:
	movew #15360,4521984
	movew 12779520,d0
	andw #127,d0
	movew d0,a2
	moveq #13,d1
	cmpl a2,d1
	jne L137
	movew #10,a2
L137:
	movel a2,sp@-
	jbsr _putc
	movel a2,d0
	jra L134
L134:
	movel a6@(-4),a2
	unlk a6
	rts
	.even
.globl _puth
_puth:
	link a6,#0
	moveml #0x3820,sp@-
	movel a6@(8),a2
	movel a6@(12),d2
	movew #14336,4521984
L139:
	subql #1,d2
	moveq #-1,d4
	cmpl d2,d4
	jeq L140
	moveb a2@,d3
	asrb #4,d3
	andb #15,d3
	cmpb #9,d3
	jhi L141
	clrl d0
	moveb d3,d0
	moveq #48,d4
	addl d4,d0
	jra L142
L141:
	clrl d1
	moveb d3,d1
	moveq #55,d0
	addl d1,d0
L142:
	movel d0,sp@-
	jbsr _putc
	moveb a2@,d3
	andb #15,d3
	addqw #1,a2
	addqw #4,sp
	cmpb #9,d3
	jhi L143
	clrl d0
	moveb d3,d0
	moveq #48,d4
	addl d4,d0
	jra L144
L143:
	clrl d1
	moveb d3,d1
	moveq #55,d0
	addl d1,d0
L144:
	movel d0,sp@-
	jbsr _putc
	addqw #4,sp
	jra L139
L140:
L138:
	moveml a6@(-16),#0x41c
	unlk a6
	rts
	.even
.globl _puts
_puts:
	link a6,#0
	movel a2,sp@-
	movel a6@(8),a2
	movew #14592,4521984
L146:
	tstb a2@
	jeq L147
	clrl d0
	moveb a2@,d0
	addqw #1,a2
	movel d0,sp@-
	jbsr _putc
	addqw #4,sp
	jra L146
L147:
L145:
	movel a6@(-4),a2
	unlk a6
	rts
	.even
.globl _putc
_putc:
	link a6,#0
	movew #14848,4521984
L149:
	movew 12779524,d0
	andw #4,d0
	tstw d0
	jne L150
	jra L149
L150:
	movew #15104,4521984
	movew a6@(10),12779520
	moveq #10,d1
	cmpl a6@(8),d1
	jne L151
	pea 13:w
	jbsr _putc
	addqw #4,sp
L151:
L148:
	unlk a6
	rts
.comm _tcount,2
.comm _nbkp,2
.comm _maxbk,2
.comm _bkadr,4
.comm _nextadr,4
.comm _autot,2

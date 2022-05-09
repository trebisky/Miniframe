LL0:
	.data
	.comm	_romregs,72
	.text
	.proc
|#PROC# 04
	.globl	_zoot
_zoot:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF13,sp
	moveml	#LS13,sp@
|#PROLOGUE# 1
	pea	_romregs
	pea	0x80027a
	jbsr	_callrom
	addqw	#0x8,sp
	moveq	#0,d0
LE13:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF13 = 0
	LS13 = 0x0
	LFF13 = 0
	LSS13 = 0x0
	LV13 = 0
	.data
	.comm	_autot,2
	.comm	_nextadr,4
	.comm	_bkadr,4
	.comm	_maxbk,2
	.comm	_nbkp,2
	.comm	_tcount,2
	.text
	.proc
|#PROC# 04
	.globl	_cmon
_cmon:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF23,sp
	moveml	#LS23,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3200,0x450000
	clrl	a5@(0x42)
	jbsr	_hwinit
	.data1
L27:
	.ascii	"\012"
	.ascii	"68010 Miniframe DISK monitor 11/08/89\012\0"
	.text
	pea	L27
	jbsr	_puts
	addqw	#0x4,sp
	clrw	_autot
	clrw	_tcount
	clrw	_nbkp
	clrl	_nextadr
	pea	a5@
	jbsr	_user
	addqw	#0x4,sp
	moveq	#0,d0
LE23:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF23 = 4
	LS23 = 0x2000
	LFF23 = 0
	LSS23 = 0x0
	LV23 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_cutrap
_cutrap:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF30,sp
	moveml	#LS30,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3f00,0x450000
	movl	#0xfff,d0
	andw	a5@(0x46),d0
	movw	d0,a6@(-0x2)
	.data1
L32:
	.ascii	"Exception vector \0"
	.text
	pea	L32
	jbsr	_puts
	addqw	#0x4,sp
	pea	0x2
	pea	a6@(-0x2)
	jbsr	_puth
	addqw	#0x8,sp
	.data1
L34:
	.ascii	" at address \0"
	.text
	pea	L34
	jbsr	_puts
	addqw	#0x4,sp
	pea	0x4
	pea	a5@(0x42)
	jbsr	_puth
	addqw	#0x8,sp
	pea	0xa
	jbsr	_putc
	addqw	#0x4,sp
	pea	a5@
	jbsr	_user
	addqw	#0x4,sp
	moveq	#0,d0
LE30:
|#PROLOGUE# 2
	moveml	a6@(-0x8),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF30 = 8
	LS30 = 0x2000
	LFF30 = 4
	LSS30 = 0x0
	LV30 = 4
	.data
	.text
	.proc
|#PROC# 04
	.globl	_cttrap
_cttrap:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF37,sp
	moveml	#LS37,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3f00,0x450000
	jbsr	_chkc
	tstl	d0
	jeq	L40
	pea	a5@
	jbsr	_user
	addqw	#0x4,sp
L40:
	tstw	_nbkp
	jeq	L41
	subqw	#0x1,_maxbk
	tstw	_maxbk
	jeq	L41
	movl	a5@(0x42),d0
	cmpl	_bkadr,d0
	jeq	L41
	jra	LE37
L41:
	.data1
L42:
	.ascii	"Trace: \0"
	.text
	pea	L42
	jbsr	_puts
	addqw	#0x4,sp
	pea	0x4
	pea	a5@(0x42)
	jbsr	_puth
	addqw	#0x8,sp
	pea	0x20
	jbsr	_putc
	addqw	#0x4,sp
	pea	0x10
	movl	a5@(0x42),sp@-
	jbsr	_puth
	addqw	#0x8,sp
	pea	0xa
	jbsr	_putc
	addqw	#0x4,sp
	tstw	_tcount
	jeq	L43
	subqw	#0x1,_tcount
	tstw	_tcount
	jeq	L43
	jra	LE37
L43:
	pea	a5@
	jbsr	_user
	addqw	#0x4,sp
	moveq	#0,d0
LE37:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF37 = 4
	LS37 = 0x2000
	LFF37 = 0
	LSS37 = 0x0
	LV37 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_user
_user:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF44,sp
	moveml	#LS44,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3d00,0x450000
	andw	#0x7fff,a5@(0x40)
	pea	a5@
	jbsr	_rdump
	addqw	#0x4,sp
L50:
	.data1
L51:
	.ascii	"TMON> \0"
	.text
	pea	L51
	jbsr	_puts
	addqw	#0x4,sp
	jbsr	_gets
	movl	d0,a6@(-0x4)
	pea	0
	pea	a6@(-0x8)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L53
	tstw	_autot
	jeq	L54
	orw	#-0x8000,a5@(0x40)
	jra	LE44
L54:
	jra	L48
L53:
	jra	L56
L57:
	pea	0x1
	pea	a5@(0x42)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	tstw	_nbkp
	jeq	L58
	orw	#-0x8000,a5@(0x40)
	movw	#0xc350,_maxbk
L58:
	jra	LE44
L59:
	pea	a5@
	jbsr	_rdump
	addqw	#0x4,sp
	jra	L55
L60:
	clrl	a6@(-0x14)
	pea	0x1
	pea	a6@(-0x14)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	movw	a6@(-0x12),_tcount
	addqw	#0x1,_autot
	orw	#-0x8000,a5@(0x40)
	tstw	_nbkp
	jeq	L61
	movw	#0x1,_maxbk
L61:
	jra	LE44
L62:
	pea	0x1
	pea	a6@(-0xc)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L63
	.data1
L64:
	.ascii	"must give start and stop address\012\0"
	.text
	pea	L64
	jbsr	_puts
	addqw	#0x4,sp
L63:
	pea	0x1
	pea	a6@(-0x10)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L65
	.data1
L66:
	.ascii	"must give start and stop address\012\0"
	.text
	pea	L66
	jbsr	_puts
	addqw	#0x4,sp
L65:
	pea	0x1
	pea	a6@(-0x14)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L67
	clrl	a6@(-0x14)
L67:
	movl	a6@(-0x14),d7
	movl	a6@(-0xc),a4
L70:
	cmpl	a6@(-0x10),a4
	jhi	L69
	movb	d7,a4@
L68:
	addqw	#0x1,a4
	jra	L70
L69:
	jra	L55
L71:
	pea	0x1
	pea	_bkadr
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L72
	tstw	_nbkp
	jeq	L73
	.data1
L74:
	.ascii	"Breakpoint cleared\012\0"
	.text
	pea	L74
	jbsr	_puts
	addqw	#0x4,sp
	clrw	_nbkp
L73:
	jra	L75
L72:
	addqw	#0x1,_nbkp
L75:
	jra	L55
L76:
L77:
L78:
L79:
	pea	0x1
	pea	a6@(-0xc)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L80
	movl	_nextadr,a6@(-0xc)
L80:
	pea	0x1
	pea	a6@(-0x10)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L81
	movl	a6@(-0xc),d0
	addl	#0xff,d0
	movl	d0,a6@(-0x10)
L81:
	movl	a6@(-0x8),sp@-
	movl	a6@(-0x10),sp@-
	movl	a6@(-0xc),sp@-
	jbsr	_dump
	lea	sp@(0xc),sp
	movl	a6@(-0x10),d0
	addql	#0x1,d0
	movl	d0,_nextadr
	jra	L55
L83:
L84:
L85:
	pea	0x1
	pea	a6@(-0xc)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L86
	movl	_nextadr,a6@(-0xc)
L86:
	movl	a6@(-0x8),sp@-
	movl	a6@(-0xc),sp@-
	jbsr	_modify
	addqw	#0x8,sp
	jra	L55
L88:
	.data1
L89:
	.ascii	"?unknown\012\0"
	.text
	pea	L89
	jbsr	_puts
	addqw	#0x4,sp
	jra	L55
L56:
	movl	a6@(-0x8),d0
	cmpl	#120,d0
	jhi	L88
	lea	L2000000,a0
	moveq	#11,d1
L2000001:	cmpb	a0@+,d0
	dbcc	d1,L2000001
	jne	L88
	addw	d1,d1
	movw	pc@(6,d1:w),d0
	jmp	pc@(2,d0:w)
L2000002:  
	.short	L77-L2000002
	.short	L78-L2000002
	.short	L79-L2000002
	.short	L83-L2000002
	.short	L84-L2000002
	.short	L85-L2000002
	.short	L76-L2000002
	.short	L62-L2000002
	.short	L57-L2000002
	.short	L59-L2000002
	.short	L60-L2000002
	.short	L71-L2000002
L2000000:  
	.byte	120
	.byte	116
	.byte	114
	.byte	103
	.byte	102
	.byte	100
	.byte	6
	.byte	5
	.byte	4
	.byte	3
	.byte	2
	.byte	1
	.even
L55:
	clrw	_autot
L48:
	jra	L50
L49:
	moveq	#0,d0
LE44:
|#PROLOGUE# 2
	moveml	a6@(-0x20),#0x3080
	unlk	a6
|#PROLOGUE# 3
	rts
	LF44 = 32
	LS44 = 0x3080
	LFF44 = 20
	LSS44 = 0x0
	LV44 = 20
	.data
	.text
	.proc
|#PROC# 04
	.globl	_skipSp
_skipSp:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF91,sp
	moveml	#LS91,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
L93:
	movl	a5@,a0
	cmpb	#0x20,a0@
	jne	L94
	addql	#0x1,a5@
	jra	L93
L94:
	moveq	#0,d0
LE91:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF91 = 4
	LS91 = 0x2000
	LFF91 = 0
	LSS91 = 0x0
	LV91 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_getArg
_getArg:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF95,sp
	moveml	#LS95,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	pea	a5@
	jbsr	_skipSp
	addqw	#0x4,sp
	movl	a5@,a0
	tstb	a0@
	jne	L97
	moveq	#-0x1,d0
	jra	LE95
L97:
	tstl	a6@(0x10)
	jne	L98
	movl	a5@,a0
	cmpb	#0x64,a0@
	jne	L99
	addql	#0x1,a5@
	movl	a5@,a0
	cmpb	#0x62,a0@
	jne	L100
	movl	a6@(0xc),a0
	movl	#0x1,a0@
	jra	L101
L100:
	movl	a5@,a0
	cmpb	#0x77,a0@
	jne	L102
	movl	a6@(0xc),a0
	movl	#0x2,a0@
	jra	L103
L102:
	movl	a5@,a0
	cmpb	#0x6c,a0@
	jne	L104
	movl	a6@(0xc),a0
	movl	#0x3,a0@
	jra	L105
L104:
	movl	a6@(0xc),a0
	movl	#0x64,a0@
L105:
L103:
L101:
	jra	L106
L99:
	movl	a5@,a0
	cmpb	#0x6d,a0@
	jne	L107
	addql	#0x1,a5@
	movl	a5@,a0
	cmpb	#0x62,a0@
	jne	L108
	movl	a6@(0xc),a0
	movl	#0x4,a0@
	jra	L109
L108:
	movl	a5@,a0
	cmpb	#0x77,a0@
	jne	L110
	movl	a6@(0xc),a0
	movl	#0x5,a0@
	jra	L111
L110:
	movl	a5@,a0
	cmpb	#0x6c,a0@
	jne	L112
	movl	a6@(0xc),a0
	movl	#0x6,a0@
	jra	L113
L112:
	movl	a6@(0xc),a0
	movl	#0x6d,a0@
L113:
L111:
L109:
	jra	L114
L107:
	movl	a5@,a0
	movb	a0@,d0
	extw	d0
	extl	d0
	andl	#0xff,d0
	movl	a6@(0xc),a0
	movl	d0,a0@
L114:
L106:
	jra	L115
L98:
	movl	a5@,sp@-
	jbsr	_getaddr
	addqw	#0x4,sp
	movl	a6@(0xc),a0
	movl	d0,a0@
L115:
L117:
	movl	a5@,a0
	tstb	a0@
	jeq	L118
	movl	a5@,a0
	cmpb	#0x20,a0@
	jeq	L118
	addql	#0x1,a5@
	jra	L117
L118:
	moveq	#0,d0
	jra	LE95
	moveq	#0,d0
LE95:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF95 = 4
	LS95 = 0x2000
	LFF95 = 0
	LSS95 = 0x0
	LV95 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_getaddr
_getaddr:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF119,sp
	moveml	#LS119,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	moveq	#0,d6
L121:
	tstb	a5@
	jeq	L122
	cmpb	#0x20,a5@
	jne	L122
	addqw	#0x1,a5
	jra	L121
L122:
L123:
	movb	a5@+,d7
	jeq	L124
	cmpb	#0x30,d7
	jcs	L125
	cmpb	#0x39,d7
	jhi	L125
	subb	#0x30,d7
	jra	L126
L125:
	cmpb	#0x61,d7
	jcs	L127
	cmpb	#0x66,d7
	jhi	L127
	subb	#0x57,d7
	jra	L128
L127:
	jra	L124
L128:
L126:
	asll	#0x4,d6
	moveq	#0,d0
	movb	d7,d0
	orl	d0,d6
	jra	L123
L124:
	movl	d6,d0
	jra	LE119
	moveq	#0,d0
LE119:
|#PROLOGUE# 2
	moveml	a6@(-0xc),#0x20c0
	unlk	a6
|#PROLOGUE# 3
	rts
	LF119 = 12
	LS119 = 0x20c0
	LFF119 = 0
	LSS119 = 0x0
	LV119 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_dump
_dump:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF129,sp
	moveml	#LS129,sp@
|#PROLOGUE# 1
	cmpl	#0x1,a6@(0x10)
	jne	L131
	moveq	#0x1,d5
	jra	L132
L131:
	cmpl	#0x2,a6@(0x10)
	jne	L133
	moveq	#0x2,d5
	jra	L134
L133:
	cmpl	#0x3,a6@(0x10)
	jne	L135
	moveq	#0x4,d5
	jra	L136
L135:
	movl	a6@(0xc),d0
	subl	a6@(0x8),d0
	addql	#0x1,d0
	movl	d0,d7
L139:
	tstl	d7
	jeq	L138
	cmpl	#0x10,d7
	jle	L2000003
	moveq	#0x10,d0
	jra	L2000004
L2000003:
	movl	d7,d0
L2000004:
	movl	d0,d6
	pea	0x4
	pea	a6@(0x8)
	jbsr	_puth
	addqw	#0x8,sp
	.data1
L140:
	.ascii	"  \0"
	.text
	pea	L140
	jbsr	_puts
	addqw	#0x4,sp
	movl	d6,sp@-
	movl	a6@(0x8),sp@-
	jbsr	_puth
	addqw	#0x8,sp
	pea	0xa
	jbsr	_putc
	addqw	#0x4,sp
	addl	d6,a6@(0x8)
L137:
	subl	d6,d7
	jra	L139
L138:
	jra	LE129
L136:
L134:
L132:
	movl	a6@(0xc),d0
	subl	a6@(0x8),d0
	addql	#0x1,d0
	movl	d0,d7
L143:
	tstl	d7
	jeq	L142
	pea	0x4
	pea	a6@(0x8)
	jbsr	_puth
	addqw	#0x8,sp
	.data1
L144:
	.ascii	"  \0"
	.text
	pea	L144
	jbsr	_puts
	addqw	#0x4,sp
	cmpl	#0x10,d7
	jle	L2000005
	moveq	#0x10,d0
	jra	L2000006
L2000005:
	movl	d7,d0
L2000006:
	movl	d0,d6
	movl	d6,d4
L147:
	tstl	d4
	jeq	L146
	cmpl	d5,d4
	jge	L2000007
	movl	d4,d0
	jra	L2000008
L2000007:
	movl	d5,d0
L2000008:
	movl	d0,d3
	movl	d3,sp@-
	movl	a6@(0x8),sp@-
	jbsr	_puth
	addqw	#0x8,sp
	addl	d3,a6@(0x8)
	pea	0x20
	jbsr	_putc
	addqw	#0x4,sp
L145:
	subl	d3,d4
	jra	L147
L146:
	pea	0xa
	jbsr	_putc
	addqw	#0x4,sp
L141:
	subl	d6,d7
	jra	L143
L142:
	moveq	#0,d0
LE129:
|#PROLOGUE# 2
	moveml	a6@(-0x14),#0xf8
	unlk	a6
|#PROLOGUE# 3
	rts
	LF129 = 20
	LS129 = 0xf8
	LFF129 = 0
	LSS129 = 0x0
	LV129 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_modify
_modify:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF148,sp
	moveml	#LS148,sp@
|#PROLOGUE# 1
	cmpl	#0x4,a6@(0xc)
	jne	L150
	movl	#0x1,a6@(-0x4)
	jra	L151
L150:
	cmpl	#0x6,a6@(0xc)
	jne	L152
	movl	#0x4,a6@(-0x4)
	andl	#-0x4,a6@(0x8)
	jra	L153
L152:
	movl	#0x2,a6@(-0x4)
	andl	#-0x2,a6@(0x8)
L153:
L151:
	movl	a6@(0x8),a6@(-0x8)
L156:
	pea	0x4
	pea	a6@(-0x8)
	jbsr	_puth
	addqw	#0x8,sp
	.data1
L157:
	.ascii	"  \0"
	.text
	pea	L157
	jbsr	_puts
	addqw	#0x4,sp
	movl	a6@(-0x4),sp@-
	movl	a6@(-0x8),sp@-
	jbsr	_puth
	addqw	#0x8,sp
	pea	0x20
	jbsr	_putc
	addqw	#0x4,sp
	movl	a6@(-0x4),sp@-
	movl	a6@(-0x8),sp@-
	jbsr	_getVal
	addqw	#0x8,sp
	tstl	d0
	jeq	L159
	jra	L155
L159:
L154:
	movl	a6@(-0x4),d0
	addl	d0,a6@(-0x8)
	jra	L156
L155:
	moveq	#0,d0
LE148:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF148 = 8
	LS148 = 0x0
	LFF148 = 8
	LSS148 = 0x0
	LV148 = 8
	.data
	.text
	.proc
|#PROC# 04
	.globl	_getVal
_getVal:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF160,sp
	moveml	#LS160,sp@
|#PROLOGUE# 1
	jbsr	_gets
	movl	d0,a6@(-0x8)
	pea	a6@(-0x8)
	jbsr	_skipSp
	addqw	#0x4,sp
	movl	a6@(-0x8),a0
	cmpb	#0x2e,a0@
	jne	L162
	moveq	#0x1,d0
	jra	LE160
L162:
	pea	0x1
	pea	a6@(-0x4)
	pea	a6@(-0x8)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L163
	moveq	#0,d0
	jra	LE160
L163:
	cmpl	#0x1,a6@(0xc)
	jne	L164
	movl	a6@(0x8),a0
	movb	a6@(-0x1),a0@
	jra	L165
L164:
	cmpl	#0x4,a6@(0xc)
	jne	L166
	movl	a6@(0x8),a0
	movl	a6@(-0x4),a0@
	jra	L167
L166:
	movl	a6@(0x8),a0
	movw	a6@(-0x2),a0@
L167:
L165:
	moveq	#0,d0
	jra	LE160
	moveq	#0,d0
LE160:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF160 = 8
	LS160 = 0x0
	LFF160 = 8
	LSS160 = 0x0
	LV160 = 8
	.data
	.text
	.proc
|#PROC# 04
	.globl	_rdump
_rdump:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF168,sp
	moveml	#LS168,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3e00,0x450000
	movl	a5,a4
	lea	a5@(0x10),a0
	movl	a0,a3
	lea	a5@(0x20),a0
	movl	a0,a2
	lea	a5@(0x30),a0
	movl	a0,a6@(-0x4)
	moveq	#0,d7
L172:
	cmpl	#0x4,d7
	jge	L171
	movl	a4,a0
	addql	#0x4,a4
	pea	a0@
	movl	d7,d0
	addl	#0x30,d0
	movl	d0,sp@-
	pea	0x64
	jbsr	_regout
	lea	sp@(0xc),sp
	movl	a3,a0
	addql	#0x4,a3
	pea	a0@
	movl	d7,d0
	addl	#0x34,d0
	movl	d0,sp@-
	pea	0x64
	jbsr	_regout
	lea	sp@(0xc),sp
	movl	a2,a0
	addql	#0x4,a2
	pea	a0@
	movl	d7,d0
	addl	#0x30,d0
	movl	d0,sp@-
	pea	0x61
	jbsr	_regout
	lea	sp@(0xc),sp
	movl	a6@(-0x4),d0
	addql	#0x4,a6@(-0x4)
	movl	d0,sp@-
	movl	d7,d0
	addl	#0x34,d0
	movl	d0,sp@-
	pea	0x61
	jbsr	_regout
	lea	sp@(0xc),sp
	pea	0xa
	jbsr	_putc
	addqw	#0x4,sp
L170:
	addql	#0x1,d7
	jra	L172
L171:
	pea	a5@(0x42)
	pea	0x63
	pea	0x70
	jbsr	_regout
	lea	sp@(0xc),sp
	.data1
L174:
	.ascii	"   sr: \0"
	.text
	pea	L174
	jbsr	_puts
	addqw	#0x4,sp
	pea	0x2
	pea	a5@(0x40)
	jbsr	_puth
	addqw	#0x8,sp
	pea	0xa
	jbsr	_putc
	addqw	#0x4,sp
	moveq	#0,d0
LE168:
|#PROLOGUE# 2
	moveml	a6@(-0x18),#0x3c80
	unlk	a6
|#PROLOGUE# 3
	rts
	LF168 = 24
	LS168 = 0x3c80
	LFF168 = 4
	LSS168 = 0x0
	LV168 = 4
	.data
	.text
	.proc
|#PROC# 04
	.globl	_regout
_regout:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF175,sp
	moveml	#LS175,sp@
|#PROLOGUE# 1
	.data1
L177:
	.ascii	"   \0"
	.text
	pea	L177
	jbsr	_puts
	addqw	#0x4,sp
	movl	a6@(0x8),sp@-
	jbsr	_putc
	addqw	#0x4,sp
	movl	a6@(0xc),sp@-
	jbsr	_putc
	addqw	#0x4,sp
	.data1
L178:
	.ascii	": \0"
	.text
	pea	L178
	jbsr	_puts
	addqw	#0x4,sp
	pea	0x4
	movl	a6@(0x10),sp@-
	jbsr	_puth
	addqw	#0x8,sp
	moveq	#0,d0
LE175:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF175 = 0
	LS175 = 0x0
	LFF175 = 0
	LSS175 = 0x0
	LV175 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_hwinit
_hwinit:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF179,sp
	moveml	#LS179,sp@
|#PROLOGUE# 1
	movw	#0x3300,0x450000
	pea	0x8
	pea	0
	jbsr	_sbaud
	addqw	#0x8,sp
	pea	0x8
	pea	0x1
	jbsr	_sbaud
	addqw	#0x8,sp
	jbsr	_cini
	moveq	#0,d0
LE179:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF179 = 0
	LS179 = 0x0
	LFF179 = 0
	LSS179 = 0x0
	LV179 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_cini
_cini:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF183,sp
	moveml	#LS183,sp@
|#PROLOGUE# 1
	movw	#0x3400,0x450000
	clrw	0xc3000c
	clrw	0xc30008
	movw	#0x18,0xc30004
	movw	#0x18,0xc30004
	movw	#0x2,0xc30004
	clrw	0xc30004
	movw	#0x4,0xc30004
	movw	#0x44,0xc30004
	movw	#0x3,0xc30004
	movw	#0xc1,0xc30004
	movw	#0x5,0xc30004
	movw	#0xea,0xc30004
	movw	#0x1,0xc30004
	clrw	0xc30004
	moveq	#0,d0
LE183:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF183 = 0
	LS183 = 0x0
	LFF183 = 0
	LSS183 = 0x0
	LV183 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_nop
_nop:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF186,sp
	moveml	#LS186,sp@
|#PROLOGUE# 1
	moveq	#0,d0
LE186:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF186 = 0
	LS186 = 0x0
	LFF186 = 0
	LSS186 = 0x0
	LV186 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_sbaud
_sbaud:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF188,sp
	moveml	#LS188,sp@
|#PROLOGUE# 1
	movw	#0x3500,0x450000
	tstl	a6@(0x8)
	jne	L190
	movw	#0x36,0xc40006
	jbsr	_nop
	movl	a6@(0xc),d0
	andl	#0xff,d0
	movw	d0,0xc40000
	jbsr	_nop
	movl	a6@(0xc),d0
	asrl	#0x8,d0
	movw	d0,0xc40000
	jra	L191
L190:
	movw	#0x76,0xc40006
	jbsr	_nop
	movl	a6@(0xc),d0
	andl	#0xff,d0
	movw	d0,0xc40002
	jbsr	_nop
	movl	a6@(0xc),d0
	asrl	#0x8,d0
	movw	d0,0xc40002
L191:
	moveq	#0,d0
LE188:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF188 = 0
	LS188 = 0x0
	LFF188 = 0
	LSS188 = 0x0
	LV188 = 0
	.data
	.text
	.proc
|#PROC# 0102
	.globl	_gets
_gets:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF192,sp
	moveml	#LS192,sp@
|#PROLOGUE# 1
	.bss
	.even
	.lcomm	L194,128
	.text
	movl	#L194,a5
	movw	#0x3600,0x450000
L196:
	jbsr	_getc
	movb	d0,d7
	cmpb	#0xa,d0
	jeq	L197
	cmpb	#0x41,d7
	jcs	L198
	cmpb	#0x5a,d7
	jhi	L198
	addb	#0x20,d7
L198:
	cmpl	#L194+0x7f,a5
	jcc	L199
	movb	d7,a5@+
L199:
	jra	L196
L197:
	clrb	a5@
	movl	#L194,d0
	jra	LE192
	moveq	#0,d0
LE192:
|#PROLOGUE# 2
	moveml	a6@(-0x8),#0x2080
	unlk	a6
|#PROLOGUE# 3
	rts
	LF192 = 8
	LS192 = 0x2080
	LFF192 = 0
	LSS192 = 0x0
	LV192 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_chkc
_chkc:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF200,sp
	moveml	#LS200,sp@
|#PROLOGUE# 1
	movw	0xc30004,d0
	extl	d0
	andl	#0x1,d0
	jne	L202
	moveq	#0,d0
	jra	LE200
L202:
	movw	0xc30000,d0
	extl	d0
	andl	#0x7f,d0
	movl	d0,d7
	jbsr	_chkc
	moveq	#0x1,d0
	jra	LE200
	moveq	#0,d0
LE200:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x80
	unlk	a6
|#PROLOGUE# 3
	rts
	LF200 = 4
	LS200 = 0x80
	LFF200 = 0
	LSS200 = 0x0
	LV200 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_getc
_getc:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF203,sp
	moveml	#LS203,sp@
|#PROLOGUE# 1
	movw	#0x3700,0x450000
L205:
	movw	0xc30004,d0
	extl	d0
	andl	#0x1,d0
	jne	L206
	jra	L205
L206:
	movw	#0x3c00,0x450000
	movw	0xc30000,d0
	extl	d0
	andl	#0x7f,d0
	movl	d0,d7
	cmpl	#0xd,d7
	jne	L207
	moveq	#0xa,d7
L207:
	movl	d7,sp@-
	jbsr	_putc
	addqw	#0x4,sp
	movl	d7,d0
	jra	LE203
	moveq	#0,d0
LE203:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x80
	unlk	a6
|#PROLOGUE# 3
	rts
	LF203 = 4
	LS203 = 0x80
	LFF203 = 0
	LSS203 = 0x0
	LV203 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_puth
_puth:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF208,sp
	moveml	#LS208,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movl	a6@(0xc),d7
	movw	#0x3800,0x450000
L210:
	movl	d7,d0
	subql	#0x1,d7
	tstl	d0
	jeq	L211
	movb	a5@,d0
	asrb	#0x4,d0
	moveq	#0xf,d1
	andb	d1,d0
	movb	d0,d6
	cmpb	#0xa,d6
	jcc	L2000009
	moveq	#0,d0
	movb	d6,d0
	addl	#0x30,d0
	jra	L2000010
L2000009:
	moveq	#0,d0
	movb	d6,d0
	addl	#0x37,d0
L2000010:
	movl	d0,sp@-
	jbsr	_putc
	addqw	#0x4,sp
	moveq	#0xf,d0
	andb	a5@+,d0
	movb	d0,d6
	cmpb	#0xa,d6
	jcc	L2000011
	moveq	#0,d0
	movb	d6,d0
	addl	#0x30,d0
	jra	L2000012
L2000011:
	moveq	#0,d0
	movb	d6,d0
	addl	#0x37,d0
L2000012:
	movl	d0,sp@-
	jbsr	_putc
	addqw	#0x4,sp
	jra	L210
L211:
	moveq	#0,d0
LE208:
|#PROLOGUE# 2
	moveml	a6@(-0xc),#0x20c0
	unlk	a6
|#PROLOGUE# 3
	rts
	LF208 = 12
	LS208 = 0x20c0
	LFF208 = 0
	LSS208 = 0x0
	LV208 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_puts
_puts:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF212,sp
	moveml	#LS212,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3900,0x450000
L214:
	tstb	a5@
	jeq	L215
	moveq	#0,d0
	movb	a5@+,d0
	movl	d0,sp@-
	jbsr	_putc
	addqw	#0x4,sp
	jra	L214
L215:
	moveq	#0,d0
LE212:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF212 = 4
	LS212 = 0x2000
	LFF212 = 0
	LSS212 = 0x0
	LV212 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_putc
_putc:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF216,sp
	moveml	#LS216,sp@
|#PROLOGUE# 1
	movw	#0x3a00,0x450000
L218:
	movw	0xc30004,d0
	extl	d0
	andl	#0x4,d0
	jne	L219
	jra	L218
L219:
	movw	#0x3b00,0x450000
	movw	a6@(0xa),0xc30000
	cmpl	#0xa,a6@(0x8)
	jne	L220
	pea	0xd
	jbsr	_putc
	addqw	#0x4,sp
L220:
	moveq	#0,d0
LE216:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF216 = 0
	LS216 = 0x0
	LFF216 = 0
	LSS216 = 0x0
	LV216 = 0
	.data

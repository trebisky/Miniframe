LL0:
	.data
	.comm	_romregs,72
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
	addl	#-LF19,sp
	moveml	#LS19,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3200,0x450000
	movl	#0x80017a,a5@(0x42)
	jbsr	_hwinit
	.data1
L23:
	.ascii	"\012"
	.ascii	"68010 Miniframe DISK monitor 11/08/89\012\0"
	.text
	pea	L23
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
LE19:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF19 = 4
	LS19 = 0x2000
	LFF19 = 0
	LSS19 = 0x0
	LV19 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_cutrap
_cutrap:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF26,sp
	moveml	#LS26,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3f00,0x450000
	movl	#0xfff,d0
	andw	a5@(0x46),d0
	movw	d0,a6@(-0x2)
	.data1
L28:
	.ascii	"Exception vector \0"
	.text
	pea	L28
	jbsr	_puts
	addqw	#0x4,sp
	pea	0x2
	pea	a6@(-0x2)
	jbsr	_puth
	addqw	#0x8,sp
	.data1
L30:
	.ascii	" at address \0"
	.text
	pea	L30
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
LE26:
|#PROLOGUE# 2
	moveml	a6@(-0x8),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF26 = 8
	LS26 = 0x2000
	LFF26 = 4
	LSS26 = 0x0
	LV26 = 4
	.data
	.text
	.proc
|#PROC# 04
	.globl	_cttrap
_cttrap:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF33,sp
	moveml	#LS33,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3f00,0x450000
	jbsr	_chkc
	tstl	d0
	jeq	L36
	pea	a5@
	jbsr	_user
	addqw	#0x4,sp
L36:
	tstw	_nbkp
	jeq	L37
	subqw	#0x1,_maxbk
	tstw	_maxbk
	jeq	L37
	movl	a5@(0x42),d0
	cmpl	_bkadr,d0
	jeq	L37
	jra	LE33
L37:
	.data1
L38:
	.ascii	"Trace: \0"
	.text
	pea	L38
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
	jeq	L39
	subqw	#0x1,_tcount
	tstw	_tcount
	jeq	L39
	jra	LE33
L39:
	pea	a5@
	jbsr	_user
	addqw	#0x4,sp
	moveq	#0,d0
LE33:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF33 = 4
	LS33 = 0x2000
	LFF33 = 0
	LSS33 = 0x0
	LV33 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_user
_user:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF40,sp
	moveml	#LS40,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3d00,0x450000
	andw	#0x7fff,a5@(0x40)
	pea	a5@
	jbsr	_rdump
	addqw	#0x4,sp
L46:
	.data1
L47:
	.ascii	"TMON> \0"
	.text
	pea	L47
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
	jne	L49
	tstw	_autot
	jeq	L50
	orw	#-0x8000,a5@(0x40)
	jra	LE40
L50:
	jra	L44
L49:
	jra	L52
L53:
	pea	0x1
	pea	a5@(0x42)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	tstw	_nbkp
	jeq	L54
	orw	#-0x8000,a5@(0x40)
	movw	#0xc350,_maxbk
L54:
	jra	LE40
L55:
	jbsr	_ckrom
	jra	L51
L57:
	pea	a5@
	jbsr	_rdump
	addqw	#0x4,sp
	jra	L51
L58:
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
	jeq	L59
	movw	#0x1,_maxbk
L59:
	jra	LE40
L60:
	pea	0x1
	pea	a6@(-0xc)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L61
	.data1
L62:
	.ascii	"must give start and stop address\012\0"
	.text
	pea	L62
	jbsr	_puts
	addqw	#0x4,sp
L61:
	pea	0x1
	pea	a6@(-0x10)
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
	pea	a6@(-0x14)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L65
	clrl	a6@(-0x14)
L65:
	movl	a6@(-0x14),d7
	movl	a6@(-0xc),a4
L68:
	cmpl	a6@(-0x10),a4
	jhi	L67
	movb	d7,a4@
L66:
	addqw	#0x1,a4
	jra	L68
L67:
	jra	L51
L69:
	pea	0x1
	pea	_bkadr
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L70
	tstw	_nbkp
	jeq	L71
	.data1
L72:
	.ascii	"Breakpoint cleared\012\0"
	.text
	pea	L72
	jbsr	_puts
	addqw	#0x4,sp
	clrw	_nbkp
L71:
	jra	L73
L70:
	addqw	#0x1,_nbkp
L73:
	jra	L51
L74:
L75:
L76:
L77:
	pea	0x1
	pea	a6@(-0xc)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L78
	movl	_nextadr,a6@(-0xc)
L78:
	pea	0x1
	pea	a6@(-0x10)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L79
	movl	a6@(-0xc),d0
	addl	#0xff,d0
	movl	d0,a6@(-0x10)
L79:
	movl	a6@(-0x8),sp@-
	movl	a6@(-0x10),sp@-
	movl	a6@(-0xc),sp@-
	jbsr	_dump
	lea	sp@(0xc),sp
	movl	a6@(-0x10),d0
	addql	#0x1,d0
	movl	d0,_nextadr
	jra	L51
L81:
L82:
L83:
	pea	0x1
	pea	a6@(-0xc)
	pea	a6@(-0x4)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L84
	movl	_nextadr,a6@(-0xc)
L84:
	movl	a6@(-0x8),sp@-
	movl	a6@(-0xc),sp@-
	jbsr	_modify
	addqw	#0x8,sp
	jra	L51
L86:
	.data1
L87:
	.ascii	"?unknown\012\0"
	.text
	pea	L87
	jbsr	_puts
	addqw	#0x4,sp
	jra	L51
L52:
	movl	a6@(-0x8),d0
	cmpl	#120,d0
	jhi	L86
	lea	L2000000,a0
	moveq	#12,d1
L2000001:	cmpb	a0@+,d0
	dbcc	d1,L2000001
	jne	L86
	addw	d1,d1
	movw	pc@(6,d1:w),d0
	jmp	pc@(2,d0:w)
L2000002:  
	.short	L75-L2000002
	.short	L76-L2000002
	.short	L77-L2000002
	.short	L81-L2000002
	.short	L82-L2000002
	.short	L83-L2000002
	.short	L55-L2000002
	.short	L74-L2000002
	.short	L60-L2000002
	.short	L53-L2000002
	.short	L57-L2000002
	.short	L58-L2000002
	.short	L69-L2000002
L2000000:  
	.byte	120
	.byte	116
	.byte	114
	.byte	103
	.byte	102
	.byte	100
	.byte	99
	.byte	6
	.byte	5
	.byte	4
	.byte	3
	.byte	2
	.byte	1
	.even
L51:
	clrw	_autot
L44:
	jra	L46
L45:
	moveq	#0,d0
LE40:
|#PROLOGUE# 2
	moveml	a6@(-0x20),#0x3080
	unlk	a6
|#PROLOGUE# 3
	rts
	LF40 = 32
	LS40 = 0x3080
	LFF40 = 20
	LSS40 = 0x0
	LV40 = 20
	.data
	.text
	.proc
|#PROC# 04
	.globl	_ckrom
_ckrom:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF88,sp
	moveml	#LS88,sp@
|#PROLOGUE# 1
	movw	#0x2700,_romregs+0x40
	clrw	_romregs+0x46
	movl	#0x800396,_romregs+0x42
	.data1
L90:
	.ascii	"calling...\0"
	.text
	pea	L90
	jbsr	_puts
	addqw	#0x4,sp
	pea	_romregs
	jbsr	_callrom
	addqw	#0x4,sp
	.data1
L92:
	.ascii	".back\012\0"
	.text
	pea	L92
	jbsr	_puts
	addqw	#0x4,sp
	moveq	#0,d0
LE88:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF88 = 0
	LS88 = 0x0
	LFF88 = 0
	LSS88 = 0x0
	LV88 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_skipSp
_skipSp:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF94,sp
	moveml	#LS94,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
L96:
	movl	a5@,a0
	cmpb	#0x20,a0@
	jne	L97
	addql	#0x1,a5@
	jra	L96
L97:
	moveq	#0,d0
LE94:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF94 = 4
	LS94 = 0x2000
	LFF94 = 0
	LSS94 = 0x0
	LV94 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_getArg
_getArg:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF98,sp
	moveml	#LS98,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	pea	a5@
	jbsr	_skipSp
	addqw	#0x4,sp
	movl	a5@,a0
	tstb	a0@
	jne	L100
	moveq	#-0x1,d0
	jra	LE98
L100:
	tstl	a6@(0x10)
	jne	L101
	movl	a5@,a0
	cmpb	#0x64,a0@
	jne	L102
	addql	#0x1,a5@
	movl	a5@,a0
	cmpb	#0x62,a0@
	jne	L103
	movl	a6@(0xc),a0
	movl	#0x1,a0@
	jra	L104
L103:
	movl	a5@,a0
	cmpb	#0x77,a0@
	jne	L105
	movl	a6@(0xc),a0
	movl	#0x2,a0@
	jra	L106
L105:
	movl	a5@,a0
	cmpb	#0x6c,a0@
	jne	L107
	movl	a6@(0xc),a0
	movl	#0x3,a0@
	jra	L108
L107:
	movl	a6@(0xc),a0
	movl	#0x64,a0@
L108:
L106:
L104:
	jra	L109
L102:
	movl	a5@,a0
	cmpb	#0x6d,a0@
	jne	L110
	addql	#0x1,a5@
	movl	a5@,a0
	cmpb	#0x62,a0@
	jne	L111
	movl	a6@(0xc),a0
	movl	#0x4,a0@
	jra	L112
L111:
	movl	a5@,a0
	cmpb	#0x77,a0@
	jne	L113
	movl	a6@(0xc),a0
	movl	#0x5,a0@
	jra	L114
L113:
	movl	a5@,a0
	cmpb	#0x6c,a0@
	jne	L115
	movl	a6@(0xc),a0
	movl	#0x6,a0@
	jra	L116
L115:
	movl	a6@(0xc),a0
	movl	#0x6d,a0@
L116:
L114:
L112:
	jra	L117
L110:
	movl	a5@,a0
	movb	a0@,d0
	extw	d0
	extl	d0
	andl	#0xff,d0
	movl	a6@(0xc),a0
	movl	d0,a0@
L117:
L109:
	jra	L118
L101:
	movl	a5@,sp@-
	jbsr	_getaddr
	addqw	#0x4,sp
	movl	a6@(0xc),a0
	movl	d0,a0@
L118:
L120:
	movl	a5@,a0
	tstb	a0@
	jeq	L121
	movl	a5@,a0
	cmpb	#0x20,a0@
	jeq	L121
	addql	#0x1,a5@
	jra	L120
L121:
	moveq	#0,d0
	jra	LE98
	moveq	#0,d0
LE98:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF98 = 4
	LS98 = 0x2000
	LFF98 = 0
	LSS98 = 0x0
	LV98 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_getaddr
_getaddr:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF122,sp
	moveml	#LS122,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	moveq	#0,d6
L124:
	tstb	a5@
	jeq	L125
	cmpb	#0x20,a5@
	jne	L125
	addqw	#0x1,a5
	jra	L124
L125:
L126:
	movb	a5@+,d7
	jeq	L127
	cmpb	#0x30,d7
	jcs	L128
	cmpb	#0x39,d7
	jhi	L128
	subb	#0x30,d7
	jra	L129
L128:
	cmpb	#0x61,d7
	jcs	L130
	cmpb	#0x66,d7
	jhi	L130
	subb	#0x57,d7
	jra	L131
L130:
	jra	L127
L131:
L129:
	asll	#0x4,d6
	moveq	#0,d0
	movb	d7,d0
	orl	d0,d6
	jra	L126
L127:
	movl	d6,d0
	jra	LE122
	moveq	#0,d0
LE122:
|#PROLOGUE# 2
	moveml	a6@(-0xc),#0x20c0
	unlk	a6
|#PROLOGUE# 3
	rts
	LF122 = 12
	LS122 = 0x20c0
	LFF122 = 0
	LSS122 = 0x0
	LV122 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_dump
_dump:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF132,sp
	moveml	#LS132,sp@
|#PROLOGUE# 1
	cmpl	#0x1,a6@(0x10)
	jne	L134
	moveq	#0x1,d5
	jra	L135
L134:
	cmpl	#0x2,a6@(0x10)
	jne	L136
	moveq	#0x2,d5
	jra	L137
L136:
	cmpl	#0x3,a6@(0x10)
	jne	L138
	moveq	#0x4,d5
	jra	L139
L138:
	movl	a6@(0xc),d0
	subl	a6@(0x8),d0
	addql	#0x1,d0
	movl	d0,d7
L142:
	tstl	d7
	jeq	L141
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
L143:
	.ascii	"  \0"
	.text
	pea	L143
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
L140:
	subl	d6,d7
	jra	L142
L141:
	jra	LE132
L139:
L137:
L135:
	movl	a6@(0xc),d0
	subl	a6@(0x8),d0
	addql	#0x1,d0
	movl	d0,d7
L146:
	tstl	d7
	jeq	L145
	pea	0x4
	pea	a6@(0x8)
	jbsr	_puth
	addqw	#0x8,sp
	.data1
L147:
	.ascii	"  \0"
	.text
	pea	L147
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
L150:
	tstl	d4
	jeq	L149
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
L148:
	subl	d3,d4
	jra	L150
L149:
	pea	0xa
	jbsr	_putc
	addqw	#0x4,sp
L144:
	subl	d6,d7
	jra	L146
L145:
	moveq	#0,d0
LE132:
|#PROLOGUE# 2
	moveml	a6@(-0x14),#0xf8
	unlk	a6
|#PROLOGUE# 3
	rts
	LF132 = 20
	LS132 = 0xf8
	LFF132 = 0
	LSS132 = 0x0
	LV132 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_modify
_modify:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF151,sp
	moveml	#LS151,sp@
|#PROLOGUE# 1
	cmpl	#0x4,a6@(0xc)
	jne	L153
	movl	#0x1,a6@(-0x4)
	jra	L154
L153:
	cmpl	#0x6,a6@(0xc)
	jne	L155
	movl	#0x4,a6@(-0x4)
	andl	#-0x4,a6@(0x8)
	jra	L156
L155:
	movl	#0x2,a6@(-0x4)
	andl	#-0x2,a6@(0x8)
L156:
L154:
	movl	a6@(0x8),a6@(-0x8)
L159:
	pea	0x4
	pea	a6@(-0x8)
	jbsr	_puth
	addqw	#0x8,sp
	.data1
L160:
	.ascii	"  \0"
	.text
	pea	L160
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
	jeq	L162
	jra	L158
L162:
L157:
	movl	a6@(-0x4),d0
	addl	d0,a6@(-0x8)
	jra	L159
L158:
	moveq	#0,d0
LE151:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF151 = 8
	LS151 = 0x0
	LFF151 = 8
	LSS151 = 0x0
	LV151 = 8
	.data
	.text
	.proc
|#PROC# 04
	.globl	_getVal
_getVal:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF163,sp
	moveml	#LS163,sp@
|#PROLOGUE# 1
	jbsr	_gets
	movl	d0,a6@(-0x8)
	pea	a6@(-0x8)
	jbsr	_skipSp
	addqw	#0x4,sp
	movl	a6@(-0x8),a0
	cmpb	#0x2e,a0@
	jne	L165
	moveq	#0x1,d0
	jra	LE163
L165:
	pea	0x1
	pea	a6@(-0x4)
	pea	a6@(-0x8)
	jbsr	_getArg
	lea	sp@(0xc),sp
	cmpl	#-0x1,d0
	jne	L166
	moveq	#0,d0
	jra	LE163
L166:
	cmpl	#0x1,a6@(0xc)
	jne	L167
	movl	a6@(0x8),a0
	movb	a6@(-0x1),a0@
	jra	L168
L167:
	cmpl	#0x4,a6@(0xc)
	jne	L169
	movl	a6@(0x8),a0
	movl	a6@(-0x4),a0@
	jra	L170
L169:
	movl	a6@(0x8),a0
	movw	a6@(-0x2),a0@
L170:
L168:
	moveq	#0,d0
	jra	LE163
	moveq	#0,d0
LE163:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF163 = 8
	LS163 = 0x0
	LFF163 = 8
	LSS163 = 0x0
	LV163 = 8
	.data
	.text
	.proc
|#PROC# 04
	.globl	_rdump
_rdump:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF171,sp
	moveml	#LS171,sp@
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
L175:
	cmpl	#0x4,d7
	jge	L174
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
L173:
	addql	#0x1,d7
	jra	L175
L174:
	pea	a5@(0x42)
	pea	0x63
	pea	0x70
	jbsr	_regout
	lea	sp@(0xc),sp
	.data1
L177:
	.ascii	"   sr: \0"
	.text
	pea	L177
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
LE171:
|#PROLOGUE# 2
	moveml	a6@(-0x18),#0x3c80
	unlk	a6
|#PROLOGUE# 3
	rts
	LF171 = 24
	LS171 = 0x3c80
	LFF171 = 4
	LSS171 = 0x0
	LV171 = 4
	.data
	.text
	.proc
|#PROC# 04
	.globl	_regout
_regout:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF178,sp
	moveml	#LS178,sp@
|#PROLOGUE# 1
	.data1
L180:
	.ascii	"   \0"
	.text
	pea	L180
	jbsr	_puts
	addqw	#0x4,sp
	movl	a6@(0x8),sp@-
	jbsr	_putc
	addqw	#0x4,sp
	movl	a6@(0xc),sp@-
	jbsr	_putc
	addqw	#0x4,sp
	.data1
L181:
	.ascii	": \0"
	.text
	pea	L181
	jbsr	_puts
	addqw	#0x4,sp
	pea	0x4
	movl	a6@(0x10),sp@-
	jbsr	_puth
	addqw	#0x8,sp
	moveq	#0,d0
LE178:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF178 = 0
	LS178 = 0x0
	LFF178 = 0
	LSS178 = 0x0
	LV178 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_hwinit
_hwinit:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF182,sp
	moveml	#LS182,sp@
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
LE182:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF182 = 0
	LS182 = 0x0
	LFF182 = 0
	LSS182 = 0x0
	LV182 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_cini
_cini:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF186,sp
	moveml	#LS186,sp@
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
	.globl	_nop
_nop:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF189,sp
	moveml	#LS189,sp@
|#PROLOGUE# 1
	moveq	#0,d0
LE189:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF189 = 0
	LS189 = 0x0
	LFF189 = 0
	LSS189 = 0x0
	LV189 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_sbaud
_sbaud:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF191,sp
	moveml	#LS191,sp@
|#PROLOGUE# 1
	movw	#0x3500,0x450000
	tstl	a6@(0x8)
	jne	L193
	movw	#0x36,0xc40006
	jbsr	_nop
	movl	a6@(0xc),d0
	andl	#0xff,d0
	movw	d0,0xc40000
	jbsr	_nop
	movl	a6@(0xc),d0
	asrl	#0x8,d0
	movw	d0,0xc40000
	jra	L194
L193:
	movw	#0x76,0xc40006
	jbsr	_nop
	movl	a6@(0xc),d0
	andl	#0xff,d0
	movw	d0,0xc40002
	jbsr	_nop
	movl	a6@(0xc),d0
	asrl	#0x8,d0
	movw	d0,0xc40002
L194:
	moveq	#0,d0
LE191:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF191 = 0
	LS191 = 0x0
	LFF191 = 0
	LSS191 = 0x0
	LV191 = 0
	.data
	.text
	.proc
|#PROC# 0102
	.globl	_gets
_gets:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF195,sp
	moveml	#LS195,sp@
|#PROLOGUE# 1
	.bss
	.even
	.lcomm	L197,128
	.text
	movl	#L197,a5
	movw	#0x3600,0x450000
L199:
	jbsr	_getc
	movb	d0,d7
	cmpb	#0xa,d0
	jeq	L200
	cmpb	#0x41,d7
	jcs	L201
	cmpb	#0x5a,d7
	jhi	L201
	addb	#0x20,d7
L201:
	cmpl	#L197+0x7f,a5
	jcc	L202
	movb	d7,a5@+
L202:
	jra	L199
L200:
	clrb	a5@
	movl	#L197,d0
	jra	LE195
	moveq	#0,d0
LE195:
|#PROLOGUE# 2
	moveml	a6@(-0x8),#0x2080
	unlk	a6
|#PROLOGUE# 3
	rts
	LF195 = 8
	LS195 = 0x2080
	LFF195 = 0
	LSS195 = 0x0
	LV195 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_chkc
_chkc:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF203,sp
	moveml	#LS203,sp@
|#PROLOGUE# 1
	movw	0xc30004,d0
	extl	d0
	andl	#0x1,d0
	jne	L205
	moveq	#0,d0
	jra	LE203
L205:
	movw	0xc30000,d0
	extl	d0
	andl	#0x7f,d0
	movl	d0,d7
	jbsr	_chkc
	moveq	#0x1,d0
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
	.globl	_getc
_getc:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF206,sp
	moveml	#LS206,sp@
|#PROLOGUE# 1
	movw	#0x3700,0x450000
L208:
	movw	0xc30004,d0
	extl	d0
	andl	#0x1,d0
	jne	L209
	jra	L208
L209:
	movw	#0x3c00,0x450000
	movw	0xc30000,d0
	extl	d0
	andl	#0x7f,d0
	movl	d0,d7
	cmpl	#0xd,d7
	jne	L210
	moveq	#0xa,d7
L210:
	movl	d7,sp@-
	jbsr	_putc
	addqw	#0x4,sp
	movl	d7,d0
	jra	LE206
	moveq	#0,d0
LE206:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x80
	unlk	a6
|#PROLOGUE# 3
	rts
	LF206 = 4
	LS206 = 0x80
	LFF206 = 0
	LSS206 = 0x0
	LV206 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_puth
_puth:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF211,sp
	moveml	#LS211,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movl	a6@(0xc),d7
	movw	#0x3800,0x450000
L213:
	movl	d7,d0
	subql	#0x1,d7
	tstl	d0
	jeq	L214
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
	jra	L213
L214:
	moveq	#0,d0
LE211:
|#PROLOGUE# 2
	moveml	a6@(-0xc),#0x20c0
	unlk	a6
|#PROLOGUE# 3
	rts
	LF211 = 12
	LS211 = 0x20c0
	LFF211 = 0
	LSS211 = 0x0
	LV211 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_puts
_puts:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF215,sp
	moveml	#LS215,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movw	#0x3900,0x450000
L217:
	tstb	a5@
	jeq	L218
	moveq	#0,d0
	movb	a5@+,d0
	movl	d0,sp@-
	jbsr	_putc
	addqw	#0x4,sp
	jra	L217
L218:
	moveq	#0,d0
LE215:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF215 = 4
	LS215 = 0x2000
	LFF215 = 0
	LSS215 = 0x0
	LV215 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_putc
_putc:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF219,sp
	moveml	#LS219,sp@
|#PROLOGUE# 1
	movw	#0x3a00,0x450000
L221:
	movw	0xc30004,d0
	extl	d0
	andl	#0x4,d0
	jne	L222
	jra	L221
L222:
	movw	#0x3b00,0x450000
	movw	a6@(0xa),0xc30000
	cmpl	#0xa,a6@(0x8)
	jne	L223
	pea	0xd
	jbsr	_putc
	addqw	#0x4,sp
L223:
	moveq	#0,d0
LE219:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF219 = 0
	LS219 = 0x0
	LFF219 = 0
	LSS219 = 0x0
	LV219 = 0
	.data

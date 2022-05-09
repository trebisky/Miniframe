LL0:
	.data
	.comm	_autot,4
	.text
	.proc
|#PROC# 04
	.globl	_cmon
_cmon:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF13,sp
	moveml	#LS13,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	lea	a5@(0x42),a0
	movl	a0,a4
	movw	a4@(0x2),a4@
	movw	a5@(0x46),a4@(0x2)
	clrw	a5@(0x46)
	jbsr	_hwinit
	.data1
L17:
	.ascii	"68010 Miniframe monitor 8/29/89\012\0"
	.text
	pea	L17
	jbsr	_puts
	addqw	#0x4,sp
	clrl	_autot
	pea	a5@
	jbsr	_user
	addqw	#0x4,sp
	moveq	#0,d0
LE13:
|#PROLOGUE# 2
	moveml	a6@(-0x8),#0x3000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF13 = 8
	LS13 = 0x3000
	LFF13 = 0
	LSS13 = 0x0
	LV13 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_cutrap
_cutrap:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF20,sp
	moveml	#LS20,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movl	#0xfff,d0
	andw	a5@(0x46),d0
	movw	d0,a6@(-0x2)
	.data1
L22:
	.ascii	"Exception vector \0"
	.text
	pea	L22
	jbsr	_puts
	addqw	#0x4,sp
	pea	0x2
	pea	a6@(-0x2)
	jbsr	_puth
	addqw	#0x8,sp
	.data1
L24:
	.ascii	" at address \0"
	.text
	pea	L24
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
LE20:
|#PROLOGUE# 2
	moveml	a6@(-0x8),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF20 = 8
	LS20 = 0x2000
	LFF20 = 4
	LSS20 = 0x0
	LV20 = 4
	.data
	.text
	.proc
|#PROC# 04
	.globl	_cttrap
_cttrap:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF27,sp
	moveml	#LS27,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	.data1
L29:
	.ascii	"Trace: \0"
	.text
	pea	L29
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
	pea	a5@
	jbsr	_user
	addqw	#0x4,sp
	moveq	#0,d0
LE27:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF27 = 4
	LS27 = 0x2000
	LFF27 = 0
	LSS27 = 0x0
	LV27 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_user
_user:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF30,sp
	moveml	#LS30,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	pea	a5@
	jbsr	_rdump
	addqw	#0x4,sp
	andw	#0x7fff,a5@(0x40)
L35:
	.data1
L36:
	.ascii	"TMON> \0"
	.text
	pea	L36
	jbsr	_puts
	addqw	#0x4,sp
	pea	a6@(-0x40)
	jbsr	_gets
	addqw	#0x4,sp
	tstb	a6@(-0x40)
	jne	L38
	tstl	_autot
	jeq	L39
	orw	#-0x8000,a5@(0x40)
	jra	L34
L39:
	jra	L33
L38:
	cmpb	#0x67,a6@(-0x40)
	jne	L40
	jra	L34
L40:
	cmpb	#0x72,a6@(-0x40)
	jne	L41
	pea	a5@
	jbsr	_rdump
	addqw	#0x4,sp
L41:
	cmpb	#0x74,a6@(-0x40)
	jne	L42
	addql	#0x1,_autot
	orw	#-0x8000,a5@(0x40)
	jra	L34
L42:
	cmpb	#0x6a,a6@(-0x40)
	jne	L43
	pea	a6@(-0x3f)
	jbsr	_getaddr
	addqw	#0x4,sp
	movl	d0,a5@(0x42)
	jra	L34
L43:
	clrl	_autot
L33:
	jra	L35
L34:
	moveq	#0,d0
LE30:
|#PROLOGUE# 2
	moveml	a6@(-0x44),#0x2000
	unlk	a6
|#PROLOGUE# 3
	rts
	LF30 = 68
	LS30 = 0x2000
	LFF30 = 64
	LSS30 = 0x0
	LV30 = 64
	.data
	.text
	.proc
|#PROC# 04
	.globl	_getaddr
_getaddr:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF45,sp
	moveml	#LS45,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	moveq	#0,d6
L47:
	tstb	a5@
	jeq	L48
	cmpb	#0x20,a5@
	jne	L48
	addqw	#0x1,a5
	jra	L47
L48:
L49:
	movb	a5@+,d7
	jeq	L50
	cmpb	#0x30,d7
	jcs	L51
	cmpb	#0x39,d7
	jhi	L51
	subb	#0x30,d7
	jra	L52
L51:
	cmpb	#0x61,d7
	jcs	L53
	cmpb	#0x66,d7
	jhi	L53
	subb	#0x57,d7
	jra	L54
L53:
	jra	L50
L54:
L52:
	asll	#0x4,d6
	moveq	#0,d0
	movb	d7,d0
	orl	d0,d6
	jra	L49
L50:
	movl	d6,d0
	jra	LE45
	moveq	#0,d0
LE45:
|#PROLOGUE# 2
	moveml	a6@(-0xc),#0x20c0
	unlk	a6
|#PROLOGUE# 3
	rts
	LF45 = 12
	LS45 = 0x20c0
	LFF45 = 0
	LSS45 = 0x0
	LV45 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_rdump
_rdump:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF55,sp
	moveml	#LS55,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movl	a5,a4
	lea	a5@(0x10),a0
	movl	a0,a3
	lea	a5@(0x20),a0
	movl	a0,a2
	lea	a5@(0x30),a0
	movl	a0,a6@(-0x4)
	moveq	#0,d7
L59:
	cmpl	#0x4,d7
	jge	L58
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
L57:
	addql	#0x1,d7
	jra	L59
L58:
	pea	a5@(0x42)
	pea	0x63
	pea	0x70
	jbsr	_regout
	lea	sp@(0xc),sp
	.data1
L61:
	.ascii	"   sr: \0"
	.text
	pea	L61
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
LE55:
|#PROLOGUE# 2
	moveml	a6@(-0x18),#0x3c80
	unlk	a6
|#PROLOGUE# 3
	rts
	LF55 = 24
	LS55 = 0x3c80
	LFF55 = 4
	LSS55 = 0x0
	LV55 = 4
	.data
	.text
	.proc
|#PROC# 04
	.globl	_regout
_regout:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF62,sp
	moveml	#LS62,sp@
|#PROLOGUE# 1
	.data1
L64:
	.ascii	"   \0"
	.text
	pea	L64
	jbsr	_puts
	addqw	#0x4,sp
	movl	a6@(0x8),sp@-
	jbsr	_putc
	addqw	#0x4,sp
	movl	a6@(0xc),sp@-
	jbsr	_putc
	addqw	#0x4,sp
	.data1
L65:
	.ascii	": \0"
	.text
	pea	L65
	jbsr	_puts
	addqw	#0x4,sp
	pea	0x4
	movl	a6@(0x10),sp@-
	jbsr	_puth
	addqw	#0x8,sp
	moveq	#0,d0
LE62:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF62 = 0
	LS62 = 0x0
	LFF62 = 0
	LSS62 = 0x0
	LV62 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_hwinit
_hwinit:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF66,sp
	moveml	#LS66,sp@
|#PROLOGUE# 1
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
LE66:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF66 = 0
	LS66 = 0x0
	LFF66 = 0
	LSS66 = 0x0
	LV66 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_cini
_cini:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF70,sp
	moveml	#LS70,sp@
|#PROLOGUE# 1
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
LE70:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF70 = 0
	LS70 = 0x0
	LFF70 = 0
	LSS70 = 0x0
	LV70 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_nop
_nop:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF73,sp
	moveml	#LS73,sp@
|#PROLOGUE# 1
	moveq	#0,d0
LE73:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF73 = 0
	LS73 = 0x0
	LFF73 = 0
	LSS73 = 0x0
	LV73 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_sbaud
_sbaud:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF75,sp
	moveml	#LS75,sp@
|#PROLOGUE# 1
	tstl	a6@(0x8)
	jne	L77
	movw	#0x36,0xc40006
	jbsr	_nop
	movl	a6@(0xc),d0
	andl	#0xff,d0
	movw	d0,0xc40000
	jbsr	_nop
	movl	a6@(0xc),d0
	asrl	#0x8,d0
	movw	d0,0xc40000
	jra	L78
L77:
	movw	#0x76,0xc40006
	jbsr	_nop
	movl	a6@(0xc),d0
	andl	#0xff,d0
	movw	d0,0xc40002
	jbsr	_nop
	movl	a6@(0xc),d0
	asrl	#0x8,d0
	movw	d0,0xc40002
L78:
	moveq	#0,d0
LE75:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF75 = 0
	LS75 = 0x0
	LFF75 = 0
	LSS75 = 0x0
	LV75 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_gets
_gets:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF79,sp
	moveml	#LS79,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
L82:
	jbsr	_getc
	movb	d0,d7
	cmpb	#0xa,d0
	jeq	L83
	cmpb	#0x41,d7
	jcs	L84
	cmpb	#0x5a,d7
	jhi	L84
	addb	#0x20,d7
L84:
	movb	d7,a5@+
	jra	L82
L83:
	clrb	a5@
	moveq	#0,d0
LE79:
|#PROLOGUE# 2
	moveml	a6@(-0x8),#0x2080
	unlk	a6
|#PROLOGUE# 3
	rts
	LF79 = 8
	LS79 = 0x2080
	LFF79 = 0
	LSS79 = 0x0
	LV79 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_getc
_getc:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF85,sp
	moveml	#LS85,sp@
|#PROLOGUE# 1
L87:
	tstw	0xc30004
	jne	L2000000
	moveq	#1,d0
	jra	L2000001
L2000000:
	clrl	d0
L2000001:
	andl	#0x1,d0
	jeq	L88
	jra	L87
L88:
	movw	0xc30000,d0
	extl	d0
	andl	#0x7f,d0
	movl	d0,d7
	cmpl	#0xd,d7
	jne	L89
	moveq	#0xa,d7
L89:
	moveq	#0,d0
LE85:
|#PROLOGUE# 2
	moveml	a6@(-0x4),#0x80
	unlk	a6
|#PROLOGUE# 3
	rts
	LF85 = 4
	LS85 = 0x80
	LFF85 = 0
	LSS85 = 0x0
	LV85 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_puth
_puth:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF90,sp
	moveml	#LS90,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
	movl	a6@(0xc),d7
L92:
	movl	d7,d0
	subql	#0x1,d7
	tstl	d0
	jeq	L93
	movb	a5@,d0
	asrb	#0x4,d0
	moveq	#0xf,d1
	andb	d1,d0
	movb	d0,d6
	cmpb	#0xa,d6
	jcc	L2000002
	moveq	#0,d0
	movb	d6,d0
	addl	#0x30,d0
	jra	L2000003
L2000002:
	moveq	#0,d0
	movb	d6,d0
	addl	#0x37,d0
L2000003:
	movl	d0,sp@-
	jbsr	_putc
	addqw	#0x4,sp
	moveq	#0xf,d0
	andb	a5@+,d0
	movb	d0,d6
	cmpb	#0xa,d6
	jcc	L2000004
	moveq	#0,d0
	movb	d6,d0
	addl	#0x30,d0
	jra	L2000005
L2000004:
	moveq	#0,d0
	movb	d6,d0
	addl	#0x37,d0
L2000005:
	movl	d0,sp@-
	jbsr	_putc
	addqw	#0x4,sp
	jra	L92
L93:
	moveq	#0,d0
LE90:
|#PROLOGUE# 2
	moveml	a6@(-0xc),#0x20c0
	unlk	a6
|#PROLOGUE# 3
	rts
	LF90 = 12
	LS90 = 0x20c0
	LFF90 = 0
	LSS90 = 0x0
	LV90 = 0
	.data
	.text
	.proc
|#PROC# 04
	.globl	_puts
_puts:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF94,sp
	moveml	#LS94,sp@
|#PROLOGUE# 1
	movl	a6@(0x8),a5
L96:
	tstb	a5@
	jeq	L97
	moveq	#0,d0
	movb	a5@+,d0
	movl	d0,sp@-
	jbsr	_putc
	addqw	#0x4,sp
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
	.globl	_putc
_putc:
|#PROLOGUE# 0
	link	a6,#0
	addl	#-LF98,sp
	moveml	#LS98,sp@
|#PROLOGUE# 1
L100:
	tstw	0xc30004
	jne	L2000006
	moveq	#1,d0
	jra	L2000007
L2000006:
	clrl	d0
L2000007:
	andl	#0x4,d0
	jeq	L101
	jra	L100
L101:
	movw	a6@(0xa),0xc30000
	cmpl	#0xa,a6@(0x8)
	jne	L102
	pea	0xd
	jbsr	_putc
	addqw	#0x4,sp
L102:
	moveq	#0,d0
LE98:
|#PROLOGUE# 2
	unlk	a6
|#PROLOGUE# 3
	rts
	LF98 = 0
	LS98 = 0x0
	LFF98 = 0
	LSS98 = 0x0
	LV98 = 0
	.data

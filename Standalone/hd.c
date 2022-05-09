/*
 * Miniframe Hard Disk Interface -- standalone driver
 *	Tom Trebisky  began 1/31/90
 * TODO:
 *	Retries and error handling.
 *	Read partition info from disk label (and geometry stuff).
 *	Bad block handling.
 */

#include "../h/param.h"
#include "../ufs/inode.h"
#include "../ufs/fs.h"
#include "saio.h"
#include "../machine/hardware.h"

/* these codes are returned by hddone()	*/
#define HDD_EFLAGS	0x0100	/* reserved for controller detected errors */
#define HDD_OVERRUN	0x0200	/* (or underrun) */
#define HDD_TIMEOUT	0x0400	/* we gave up waiting */

#define NHD	2	/* miniframe only allows 2 hard drives */
#define NPART	8	/* the usual 8 disk partitions */

/* this will do for initial testing */
short	st251_off[NPART] = { 1, 101, 0, 201, 301, -1, 401, -1 };

/* for now, just wire in drive geometry for ST251-1 */
struct st hdst[NHD] = {
	17,	6,	17*6,	820,	st251_off,
	17,	6,	17*6,	820,	st251_off
};

/* here is some more ST251-1 stuff */
#define PRECOMP	900
#define STEPR	0
#define SSIZE	512

struct hdcmd {
	u_short	h_unit;		/* drive (0 or 1) */
	u_long	h_ma;		/* memory address for xfer */
	u_short	h_cc;		/* byte count for xfer */
	u_short	h_nsec;		/* sector count for xfer */
	u_short	h_cn;		/* cylinder */
	u_short	h_tn;		/* track */
	u_short	h_sn;		/* starting sector */
};

struct hd_softc {
	u_short	precomp;
	u_short	steprate;
	u_short	ssize;
};

struct hd_softc hd_softc[NHD];

hdopen(io)
register struct iob *io;
{
	register int unit = io->i_unit;
	register struct st *st = &hdst[unit];
	register struct hd_softc *sc = &hd_softc[unit];

	if ( unit < 0 || unit >= NHD )
	    _stop("unknown hd unit");

	if ( io->i_boff<0 || io->i_boff >= NPART || st->off[io->i_boff]== -1)
	    _stop("hd bad minor");
	io->i_boff = st->off[io->i_boff] * st->nspc;

	sc->ssize = SSIZE;
	sc->precomp = PRECOMP;
	sc->steprate = STEPR;

	if ( hdinit(unit) < 0 )
	    _stop("hd will not initialize");
}

hdstrategy(io, func)
register struct iob *io;
{
	struct hdcmd cmdbuf;
	register struct st *st;
	register struct hdcmd *hdc;
	int bn, sn, nsec, retval, sectsize;
	char *membase;

	hdc = &cmdbuf;
	st = &hdst[io->i_unit];

	membase = io->i_ma;
	retval = io->i_cc;
	bn = io->i_bn;

	sectsize = hd_softc[io->i_unit].ssize;
	nsec = retval / sectsize;
	hdc->h_unit = io->i_unit;

	while ( nsec ) {
	    hdc->h_cn = bn / st->nspc;
	    if ( hdc->h_cn >= st->ncyl )	/* EOF */
		break;
	    sn = bn % st->nspc;		/* sector within cylinder */
	    hdc->h_tn = sn / st->nsect;
	    hdc->h_sn = sn % st->nsect;

	    /* at most read to end of track in one operation */
	    hdc->h_nsec = MIN(st->nsect-hdc->h_sn, nsec);
	    hdc->h_cc = hdc->h_nsec * sectsize;
	    hdc->h_ma = (u_long) membase;

	    hdio ( hdc, func );

	    bn += hdc->h_nsec;
	    nsec -= hdc->h_nsec;
	    membase += hdc->h_cc;
	}

	return ( retval-nsec*sectsize );
}

hdioctl(io, cmd, arg)
struct iob *io;
int cmd;
caddr_t arg;
{
	return (ECMD);
}

hdinit(unit)
{
	int stat;
	register timeout;
	register struct hd_softc *sc = &hd_softc[unit];

	/* pulse the reset line to the HDC */
	*HD_RESET_ON = 0;
	*HD_RESET_OFF = 0;

	*DISK_BIU_RESET = 0;	/***/
	*HD_WPC = sc->precomp>>2;	/* RWC cylinder */

	if ( unit )
	    *HD_SDH = 0x28;		/* 512 byte sectors, drive 1 */
	else
	    *HD_SDH = 0x20;		/* 512 byte sectors, drive 0 */

	*HD_COMMAND = HDC_RESTORE|sc->steprate;

	if ( stat = hddone() ) {
	    printf("timeout attempting hard drive restore.\n");
	    return ( -1 );
	}
	
	if ( (stat = *HD_STATUS) & HDS_MASK ) {
	    printf("hard drive restore attempt failed.\n");
	    return ( -1 );
	}
	return ( 0 );
}

hdio (cmd,func)
register struct hdcmd *cmd;
{
	int stat;
	int code;
	register u_long dmatmp;

	/* pulse the reset line.
	 * I suspect this really should only be done in hddone()
	 * as recovery from overrun/underrun.
	 */
	*HD_RESET_ON = 0;
	*HD_RESET_OFF = 0;

	/* First, set up the dma */
	*DISK_DMA_DISABLE = 0;
	*DISK_BIU_RESET = 0;

	*DISK_DMA_COUNT = -(cmd->h_cc>>1);

	dmatmp = (cmd->h_ma) >> 1;	/* word address */
	*DISK_DMA_LADDR = dmatmp & 0xffff;

	dmatmp >>= 16;

	if ( func == READ )
	    *DISK_DMA_UADDR_R = dmatmp;
	else
	    *DISK_DMA_UADDR_W = dmatmp;

/* Second tell the controller to do the i/o */

	/* this controller does implied seeks */
	*HD_CYHIGH = cmd->h_cn>>8;
	*HD_CYLOW = cmd->h_cn;

	*HD_DMA_ENABLE = 0;

	*HD_SNUM = cmd->h_sn;

	*HD_SDH = 0x20 | cmd->h_unit<<3 | cmd->h_tn&0x07;

	if ( cmd->h_nsec == 1 ) {
	    /* single sector io (ignores HD_SCOUNT) */
	    if ( func == READ )
		*HD_COMMAND = (HDC_READ|HDC_IEOC);
	    else
		*HD_COMMAND = (HDC_WRITE);
	} else {
	    /* multi-sector io */
	    *HD_SCOUNT = cmd->h_nsec;
	    if ( func == READ )
		*HD_COMMAND = (HDC_READ|HDC_IEOC|HDC_MULT);
	    else
		*HD_COMMAND = (HDC_WRITE|HDC_MULT);
	}


	code = hddone();

	stat = *HD_STATUS;
	if ( stat & HDS_MASK )
	    code |= (HDD_EFLAGS | *HD_EFLAGS&0xff);

	if ( code ) {
	    printf("io error, drive %d, cyl %d, head %d, sector %d",
		cmd->h_unit,cmd->h_cn,cmd->h_tn,cmd->h_sn);
	    printf(" status: ");
	    hex2(stat);
	    printf(" err: ");
	    hex4(code);
	    printf("\n");
	}
	return ( code );
}

/* This must be long enough for really long seeks - the longest
 * (and slowest) is a restore when the heads were way out at cylinder
 * 800 or such - this can take several seconds.
 * (The restore is done taking one step at a time and waiting for seek
 * complete - the specified step rate is ignored.)
 */
#define PICTIMEOUT	400000		/* was 100000 */

/* note: the "interrupt" is presented only on one read by the 8259
 * when polling like this, you read 0x continuously, then once get
 * 0x8x, then back to 0x as long as you care to keep reading.
 * Also note that on this machine, when reading an 8 bit register
 * on a 16 bit bus, the upper 8 bits gets set to ones, so you get
 * 0xff8x (or 0xff0x, it is not sign extension).
 *
 */
hddone()
{
	long timeout;
	register picstat;
	register code = 0;

	*PIC_A1 = 0x9f;	/* allow levels 5 and 6 */
	timeout = PICTIMEOUT;
	while ( timeout-- ) {
	    *PIC_A0 = 0x0e;	/* polling the 8259 */
	    picstat = (*PIC_A0) & 0xff;
	    if ( picstat == 0x86 )	/* Winchester EOT */
		break;
	    if ( picstat == 0x85 ) {	/* overrun, underrun */
		code = HDD_OVERRUN;
		break;
	    }
	}
	if ( timeout == -1 )
	    code = HDD_TIMEOUT;

	*HD_SDH = 0x18;		/* impossible (select no drive) */
	*DISK_DMA_DISABLE = 0;
	*DISK_BIU_RESET = 0;
	*PIC_A1 = 0xff;		/* remask all sources */
	return ( code );
}

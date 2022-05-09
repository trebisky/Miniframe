/*
 * Miniframe Floppy Disk -- standalone driver
 *	Tom Trebisky  3/2/91
 * TODO:
 *	Retries and error handling.
 *	Other "units" will be different formats (including double sides).
 */

#include "../h/param.h"
#include "../ufs/inode.h"
#include "../ufs/fs.h"
#include "saio.h"
#include "../machine/hardware.h"

/* these codes are returned by fddone()	*/
#define FDD_EFLAGS	0x0100	/* reserved for controller detected errors */
#define FDD_TIMEOUT	0x0400	/* we gave up waiting */

#define NFD	1	/* miniframe only has 1 floppy drives */
#define NPART	8	/* the usual 8 disk partitions */
#define SSIZE 512

#ifdef RX50
/* this will do for initial testing */
short	rx50_off[NPART] = { 5, 10, 0, -1, -1, -1, -1, -1 };

/* for now, just wire in drive geometry for rx50.
 * We use a RX50 format with 80 cyl, 1 head, 10 sectors of 512 bytes,
 * for 800 blocks total (400K).
 */
struct st fdst[NFD] = {
	10,	1,	10,	80,	rx50_off,
};
#else
/* This is for the standard IBMPC 360K drive */
/* currently boot is about 12K in size, so 2 cylinders is fine */
short	ibmpc_off[NPART] = { 2, 10, 0, -1, -1, -1, -1, -1 };
struct st fdst[NFD] = {
	9,	2,	18,	40,	ibmpc_off,
};
#endif

struct fdcmd {
	u_short	h_unit;		/* drive (0 or 1) */
	u_long	h_ma;		/* memory address for xfer */
	u_short	h_cc;		/* byte count for xfer */
	u_short	h_cn;		/* cylinder */
	u_short	h_tn;		/* track */
	u_short	h_sn;		/* starting sector */
};

struct fd_softc {
	u_short	density;
	u_short	ssize;
	short curtrack;
};

struct fd_softc fd_softc[NFD];

#define SINGLE	1
#define DOUBLE	2

fdopen(io)
register struct iob *io;
{
	register int unit = io->i_unit;
	register struct st *st = &fdst[unit];
	register struct fd_softc *sc = &fd_softc[unit];

	if ( unit < 0 || unit >= NFD )
	    _stop("unknown fd unit");

	if ( io->i_boff<0 || io->i_boff >= NPART || st->off[io->i_boff]== -1)
	    _stop("fd bad minor");
	io->i_boff = st->off[io->i_boff] * st->nspc;

	sc->density = DOUBLE;
	sc->ssize = SSIZE;
	sc->curtrack = -1;

	if ( fdinit(unit) < 0 )
	    _stop("fd will not initialize");
}

fdclose(io)
register struct iob *io;
{
	*FD_MOTOR_OFF = 0;
}

fdstrategy(io, func)
register struct iob *io;
{
	struct fdcmd cmdbuf;
	register struct st *st;
	register struct fdcmd *fdc;
	int bn, sn, nsec, retval, sectsize;
	char *membase;

	fdc = &cmdbuf;
	st = &fdst[io->i_unit];

	membase = io->i_ma;
	retval = io->i_cc;
	bn = io->i_bn;

	sectsize = fd_softc[io->i_unit].ssize;
	nsec = retval / sectsize;
	fdc->h_unit = io->i_unit;

	while ( nsec ) {
	    fdc->h_cn = bn / st->nspc;
	    if ( fdc->h_cn >= st->ncyl )
		break;
	    sn = bn % st->nspc;		/* sector within cylinder */
	    fdc->h_tn = sn / st->nsect;
	    fdc->h_sn = sn % st->nsect;

	    /* floppy reads only one sector at a time */
	    fdc->h_cc = sectsize;
	    fdc->h_ma = (u_long) membase;

	    fdio ( fdc, func );

	    ++bn;
	    --nsec;
	    membase += sectsize;
	}

	return ( retval-nsec*sectsize );
}

fdioctl(io, cmd, arg)
struct iob *io;
int cmd;
caddr_t arg;
{
	return (ECMD);
}

fdinit(unit)
{
	int stat;
	register timeout;
	register struct fd_softc *sc = &fd_softc[unit];

	/* pulse the chip reset line (will do a restore) */
	*FD_RESET_ON = 0;
	*FD_RESET_OFF = 0;

	*DISK_BIU_RESET = 0;	/***/
	timeout = *FD_STATUS;	/* mysterious (from ROM code) */
	*FD_MOTOR_ON = 0;

	if ( *SC_STAT & SC_FDNP ) {
	    printf("no floppy drive present or cable wrong.\n");
	    return ( -1 );
	}

	for ( timeout=400000; timeout; --timeout )
	    if ( ! (*FD_STATUS & FD_NREADY) )
		break;

	if ( *FD_STATUS & FD_NREADY ) {
	    printf("Timeout: floppy drive not ready.\n");
	    return ( -1 );
	}

	if ( sc->density == SINGLE )
	    *FD_SINGLE = 0;
	else
	    *FD_DOUBLE = 0;


	*FD_COMMAND = 0x04;	/* restore with verify */
	if ( fddone() ) {
	    printf("timeout attempting floppy restore.\n");
	    return ( -1 );
	}

	if ( (stat = *FD_STATUS) & (FD_NREADY|FD_SEEKERR|FD_CRCERR) ) {
	    printf("floppy restore error.\n");
	    return ( -1 );
	}

	if ( ! ((stat = *FD_STATUS) & FD_TRACK0) ) {
	    printf("floppy restore failed.\n");
	    return ( -1 );
	}

	*FD_TRACK = sc->curtrack = 0;
	return ( 0 );
}

fdio (cmd,func)
register struct fdcmd *cmd;
{
	int stat;
	int code;
	register u_long dmatmp;
	register struct fd_softc *sc = &fd_softc[cmd->h_unit];

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

	*FD_DATA = cmd->h_cn;
	if ( cmd->h_cn != sc->curtrack )
	    fdseek(cmd->h_unit,cmd->h_cn);

	*FD_DMA_ENABLE = 0;

	*FD_SECTOR = cmd->h_sn + 1;

	if ( sc->density == SINGLE )
	    *FD_SINGLE = 0;
	else
	    *FD_DOUBLE = 0;

	/* using dmatmp as a scratch variable */
	if ( func == READ )
	    dmatmp = 0x88;
	else
	    dmatmp = 0xa8;

	if ( cmd->h_tn )	/* pick which side */
	    dmatmp |= 0x02;

	/* GO for it !! */
	*FD_COMMAND = dmatmp;

	code = fddone();

	stat = *FD_STATUS;
	if ( stat & (FD_NREADY|FD_WPROT|FD_RNF|FD_CRCERR|FD_LDATA) )
	    code |= ( FDD_EFLAGS | *FD_STATUS );

	if ( code ) {
	    printf("io error, floppy drive,  cyl %d, head %d, sector %d",
		cmd->h_cn,cmd->h_tn,cmd->h_sn);
	    printf(" status: ");
	    hex4(code);
	    printf("\n");
	}
	return ( code );
}

fdseek(unit,track)
{
	int stat;
	int code;
	register struct fd_softc *sc = &fd_softc[unit];

	*FD_DATA = track;

	if ( sc->density == SINGLE )
	    *FD_SINGLE = 0;
	else
	    *FD_DOUBLE = 0;

	*FD_COMMAND = 0x14;	/* seek with verify */

	code = fddone();

	stat = *FD_STATUS & 0xff;
	if ( stat & (FD_NREADY|FD_SEEKERR|FD_CRCERR) )
	    code |= ( FDD_EFLAGS | stat );

	if ( code ) {
	    printf("floppy seek error, cyl %d\n", track );
	    printf("status: ");
	    hex4(code);
	    printf("\n");
	    sc->curtrack = -1;
	} else
	    sc->curtrack = track;
	return ( code );
}

#define PICTIMEOUT	100000		/* was 400000 */
/* This must be long enough for really long seeks - the longest
 * (and slowest) is a restore when the heads were way out at cylinder
 * 80 or such - this can take several seconds.
 *
 * note: the "interrupt" is presented only on one read by the 8259
 * when polling like this, you read 07 continuously, then once get
 * 0x87, then back to 07 as long as you care to keep reading.
 * Also note that on this machine, when reading an 8 bit register
 * on a 16 bit bus, the upper 8 bits gets set to ones, so you get
 * 0xff87 (or 0xff07, it is not sign extension).
 */
fddone()
{
	long timeout;
	register picstat;
	register code = 0;

	*PIC_A1 = 0x7f;
	timeout = PICTIMEOUT;

	while ( timeout-- ) {
	    *PIC_A0 = 0x0e;
	    picstat = (*PIC_A0) & 0xff;
	    if ( picstat == 0x87 )
		break;
	}
	if ( timeout == 0 )
	    code = FDD_TIMEOUT;

	*DISK_DMA_DISABLE = 0;
/*	*DISK_BIU_RESET = 0;	*/
	*PIC_A1 = 0xff;
	return ( code );
}

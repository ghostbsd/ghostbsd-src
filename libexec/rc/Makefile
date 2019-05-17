# $FreeBSD$

CONFGROUPS=	CONFETC CONFETCEXEC CONFETCDEFAULTS
CONFETCDIR=	/etc
CONFETC+=	network.subr openrc openrc.shutdown rc rc.dynamicdiskless
CONFETC+=	rc.initdiskless rc.subr rc.shutdown
CONFETCMODE=	644
CONFETCEXEC=	netstart pccard_ether rc.devd rc.resume rc.suspend
CONFETCEXECDIR=	/etc
CONFETCEXECMODE=	755
CONFETCDEFAULTSDIR=	/etc/defaults
CONFETCDEFAULTS=	rc.conf
#PACKAGE=rc

SUBDIR+=	bin
SUBDIR+=	init.d
SUBDIR+=	rc.d
SUBDIR+=	sbin
SUBDIR+=	sh

# Needs to be added after sh
SUBDIR+=	etc.init.d

.include <bsd.prog.mk>

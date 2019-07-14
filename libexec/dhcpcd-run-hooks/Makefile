# $FreeBSD$

DHCPCDDIR=	${SRCTOP}/contrib/dhcpcd
.PATH:		${DHCPCDDIR}/hooks

WARNS?=		1
WFORMAT?=	0

FILES=	dhcpcd-run-hooks

SFILES=	dhcpcd-run-hooks \
	dhcpcd-run-hooks.8

CLEANFILES+= dhcpcd-run-hooks dhcpcd-run-hooks.8


dhcpcd-run-hooks:
	sed 's|@SHELL@|/bin/sh|g' ${SRCTOP}/contrib/dhcpcd/hooks/dhcpcd-run-hooks.in >${.TARGET}
	sed -i '' 's|@SYSCONFDIR@|/etc|g' ${.TARGET}
	sed -i '' 's|@HOOKDIR@|/libexec/dhcpcd-hooks|g' ${.TARGET}
	sed -i '' 's|@SERVICEEXISTS@||g' ${.TARGET}
	sed -i '' 's|@SERVICECMD@||g' ${.TARGET}
	sed -i '' 's|@SERVICESTATUS@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@RUNDIR@|/var/run|g' ${.TARGET}

dhcpcd-run-hooks.8:
	sed 's|@SHELL@|/bin/sh|g' ${SRCTOP}/contrib/dhcpcd/hooks/dhcpcd-run-hooks.8.in >${.TARGET}
	sed -i '' 's|@SYSCONFDIR@|/etc|g' ${.TARGET}
	sed -i '' 's|@HOOKDIR@|/libexec/dhcpcd-hooks|g' ${.TARGET}
	sed -i '' 's|@SERVICEEXISTS@||g' ${.TARGET}
	sed -i '' 's|@SERVICECMD@||g' ${.TARGET}
	sed -i '' 's|@SERVICESTATUS@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@RUNDIR@|/var/run|g' ${.TARGET}

FILESDIR=       /libexec
FILESMODE=      755

MAN=	dhcpcd-run-hooks.8

.include <bsd.prog.mk>

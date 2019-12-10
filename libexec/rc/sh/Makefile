# $FreeBSD$
#
#

SHSRC=    ${SRCTOP}/contrib/openrc/

.PATH:  ${SHSRC}/sh

SFILES=	functions \
	gendepends \
	openrc-run \
	rc-functions

FILES+=	rc-mount.sh \
	runit.sh \
	s6.sh \
	start-stop-daemon.sh \
	supervise-daemon.sh \
	init.sh \
	functions.sh \
	gendepends.sh \
	openrc-run.sh \
	rc-functions.sh

CLEANFILES+= functions.sh init.sh gendepends.sh openrc-run.sh rc-functions.sh


functions.sh:
	sed 's|@SHELL@|/bin/sh|g' ${SRCTOP}/contrib/openrc/sh/functions.sh.in >${.TARGET}
	sed -i '' 's|@LIBEXECDIR@|/libexec/rc|g' ${.TARGET}
	sed -i '' 's|@BINDIR@|/usr/local/bin|g' ${.TARGET}
	sed -i '' 's|@SBINDIR@|/usr/local/sbin|g' ${.TARGET}
	sed -i '' 's|@PKG_PREFIX@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@LOCAL_PREFIX@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@SYSCONFDIR@|/etc|g' ${.TARGET}
	sed -i '' 's|@LIB@|/lib|g' ${.TARGET}
	sed -i '' 's|@PREFIX@||g' ${.TARGET}

gendepends.sh:
	sed 's|@SHELL@|/bin/sh|g' ${SRCTOP}/contrib/openrc/sh/gendepends.sh.in >${.TARGET}
	sed -i '' 's|@LIBEXECDIR@|/libexec/rc|g' ${.TARGET}
	sed -i '' 's|@BINDIR@|/usr/local/bin|g' ${.TARGET}
	sed -i '' 's|@SBINDIR@|/usr/local/sbin|g' ${.TARGET}
	sed -i '' 's|@PKG_PREFIX@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@LOCAL_PREFIX@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@SYSCONFDIR@|/etc|g' ${.TARGET}
	sed -i '' 's|@LIB@|/lib|g' ${.TARGET}
	sed -i '' 's|@PREFIX@||g' ${.TARGET}

openrc-run.sh:
	sed 's|@SHELL@|/bin/sh|g' ${SRCTOP}/contrib/openrc/sh/openrc-run.sh.in >${.TARGET}
	sed -i '' 's|@LIBEXECDIR@|/libexec/rc|g' ${.TARGET}
	sed -i '' 's|@BINDIR@|/usr/local/bin|g' ${.TARGET}
	sed -i '' 's|@SBINDIR@|/usr/local/sbin|g' ${.TARGET}
	sed -i '' 's|@PKG_PREFIX@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@LOCAL_PREFIX@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@SYSCONFDIR@|/etc|g' ${.TARGET}
	sed -i '' 's|@LIB@|/lib|g' ${.TARGET}
	sed -i '' 's|@PREFIX@||g' ${.TARGET}

rc-functions.sh:
	sed 's|@SHELL@|/bin/sh|g' ${SRCTOP}/contrib/openrc/sh/rc-functions.sh.in >${.TARGET}
	sed -i '' 's|@LIBEXECDIR@|/libexec/rc|g' ${.TARGET}
	sed -i '' 's|@BINDIR@|/usr/local/bin|g' ${.TARGET}
	sed -i '' 's|@SBINDIR@|/usr/local/sbin|g' ${.TARGET}
	sed -i '' 's|@PKG_PREFIX@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@LOCAL_PREFIX@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@SYSCONFDIR@|/etc|g' ${.TARGET}
	sed -i '' 's|@LIB@|/lib|g' ${.TARGET}
	sed -i '' 's|@PREFIX@||g' ${.TARGET}

init.sh:
	sed 's|@SHELL@|/bin/sh|g' ${SRCTOP}/contrib/openrc/sh/init.sh.BSD.in >${.TARGET}
	sed -i '' 's|@LIBEXECDIR@|/libexec/rc|g' ${.TARGET}
	sed -i '' 's|@BINDIR@|/usr/local/bin|g' ${.TARGET}
	sed -i '' 's|@SBINDIR@|/usr/local/sbin|g' ${.TARGET}
	sed -i '' 's|@PKG_PREFIX@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@LOCAL_PREFIX@|/usr/local|g' ${.TARGET}
	sed -i '' 's|@SYSCONFDIR@|/etc|g' ${.TARGET}
	sed -i '' 's|@LIB@|/lib|g' ${.TARGET}
	sed -i '' 's|@PREFIX@||g' ${.TARGET}

FILESDIR=       /libexec/rc/sh
FILESMODE=      755

.include <bsd.prog.mk>

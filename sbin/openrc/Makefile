# $FreeBSD$

PACKAGE=runtime
PROG=	openrc
LINKS=	${BINDIR}/openrc ${BINDIR}/rc

OPENRC=	${.CURDIR}/../../contrib/openrc

RC=	${OPENRC}/src/rc
EINFO=	${OPENRC}/src/libeinfo
LIBRC=	${OPENRC}/src/librc
OLIBRC=	${.OBJDIR}/../../lib/librc/contrib/openrc/src/librc
INC=	${OPENRC}/src/includes

SRCS=	rc.c rc-logger.c rc-misc.c rc-plugin.c _usage.c rc-logger.h
CFLAGS+= -I${RC} -I${EINFO} -I${LIBRC} -I${OLIBRC} -I${INC}

WARNS?=	3
MAN=	openrc.8

LIBADD=	einfo rc util

.PATH: ${RC}
.PATH: ${OPENRC}/man

SUBDIR+=	conf.d
SUBDIR+=	local.d
SUBDIR+=	sysctl.d

.include <bsd.prog.mk>

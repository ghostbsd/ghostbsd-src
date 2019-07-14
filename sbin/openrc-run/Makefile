# $FreeBSD$

PACKAGE=runtime
PROG=	openrc-run
LINKS=  ${BINDIR}/openrc-run ${BINDIR}/runscript

OPENRC=	${.CURDIR}/../../contrib/openrc

RC=	${OPENRC}/src/rc
EINFO=	${OPENRC}/src/libeinfo
LIBRC=	${OPENRC}/src/librc
OLIBRC=	${.OBJDIR}/../../lib/librc/contrib/openrc/src/librc
INC=	${OPENRC}/src/includes

SRCS=	openrc-run.c rc-misc.c rc-plugin.c _usage.c
CFLAGS+= -I${RC} -I${EINFO} -I${LIBRC} -I${OLIBRC} -I${INC}

WARNS?=	3
MAN=	openrc-run.8

LIBADD=	einfo rc util

.PATH: ${RC}
.PATH: ${OPENRC}/man

.include <bsd.prog.mk>

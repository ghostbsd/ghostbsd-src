# $FreeBSD$

PACKAGE=runtime
PROG=	service_starting

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${ORSRC}/rc

LINKS=  ${BINDIR}/service_starting ${BINDIR}/service_started \
	${BINDIR}/service_starting ${BINDIR}/service_stopping \
	${BINDIR}/service_starting ${BINDIR}/service_stopped \
	${BINDIR}/service_starting ${BINDIR}/service_inactive \
	${BINDIR}/service_starting ${BINDIR}/service_wasinactive \
	${BINDIR}/service_starting ${BINDIR}/service_hotplugged \
	${BINDIR}/service_starting ${BINDIR}/service_started_daemon \
	${BINDIR}/service_starting ${BINDIR}/service_crashed
SRCS=	do_service.c \
	rc-misc.c
CFLAGS+=	-I${ORSRC}/rc \
		-I${ORSRC}/libeinfo \
		-I${ORSRC}/librc \
                -I${.OBJDIR}/../../../../lib/librc/contrib/openrc/src/librc \
		-I${ORSRC}/includes

WARNS?=	3

BINDIR=/libexec/rc/bin
LIBADD=	einfo kvm rc util
MAN=

.include <bsd.prog.mk>

# $FreeBSD$

PACKAGE=runtime
PROG=	mark_service_starting

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${ORSRC}/rc

LINKS=  ${BINDIR}/mark_service_starting ${BINDIR}/mark_service_started \
	${BINDIR}/mark_service_starting ${BINDIR}/mark_service_stopping \
	${BINDIR}/mark_service_starting ${BINDIR}/mark_service_stopped \
	${BINDIR}/mark_service_starting ${BINDIR}/mark_service_inactive \
	${BINDIR}/mark_service_starting ${BINDIR}/mark_service_wasinactive \
	${BINDIR}/mark_service_starting ${BINDIR}/mark_service_hotplugged \
	${BINDIR}/mark_service_starting ${BINDIR}/mark_service_failed
SRCS=	do_mark_service.c \
	rc-misc.c
CFLAGS+=	-I${ORSRC}/rc \
		-I${ORSRC}/libeinfo \
		-I${ORSRC}/librc \
                -I${.OBJDIR}/../../../../lib/librc/contrib/openrc/src/librc \
		-I${ORSRC}/includes

WARNS?=	3

BINDIR?=/libexec/rc/sbin
LIBADD=	einfo kvm rc util
MAN=

.include <bsd.prog.mk>

# $FreeBSD$

PACKAGE=runtime
PROG=	rc-service

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${ORSRC}/rc

SRCS=	rc-service.c \
	rc-misc.c \
	_usage.c
CFLAGS+=	-I${ORSRC}/rc \
		-I${ORSRC}/libeinfo \
		-I${ORSRC}/librc \
		-I${.OBJDIR}/../../lib/librc/contrib/openrc/src/librc \
		-I${ORSRC}/includes

WARNS?=	3
MAN=	${.CURDIR}/../../contrib/openrc/man/rc-service.8 \
	${.CURDIR}/../../contrib/openrc/man/service.8

LIBADD=	einfo rc util

.include <bsd.prog.mk>

# $FreeBSD$

PACKAGE=runtime
PROG=	rc-update

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${ORSRC}/rc

SRCS=	rc-update.c \
	rc-misc.c \
	_usage.c
CFLAGS+=	-I${ORSRC}/rc \
		-I${ORSRC}/libeinfo \
		-I${ORSRC}/librc \
                -I${.OBJDIR}/../../lib/librc/contrib/openrc/src/librc \
		-I${ORSRC}/includes

WARNS?=	3
MAN=	${.CURDIR}/../../contrib/openrc/man/rc-update.8

LIBADD=	einfo rc util

.include <bsd.prog.mk>

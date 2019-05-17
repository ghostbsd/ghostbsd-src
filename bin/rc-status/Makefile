# $FreeBSD$

PACKAGE=runtime
PROG=	rc-status

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${ORSRC}/rc

SRCS=	rc-status.c \
	rc-misc.c \
	_usage.c
CFLAGS+=	-I${ORSRC}/rc \
		-I${ORSRC}/libeinfo \
		-I${ORSRC}/librc \
                -I${.OBJDIR}/../../lib/librc/contrib/openrc/src/librc \
		-I${ORSRC}/includes

WARNS?=	3
MAN=	${.CURDIR}/../../contrib/openrc/man/rc-status.8

LIBADD=	einfo rc

.include <bsd.prog.mk>

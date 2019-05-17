# $FreeBSD$

PACKAGE=runtime
PROG=	rc-depend

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${ORSRC}/rc

SRCS=	rc-depend.c \
	rc-misc.c \
	_usage.c
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

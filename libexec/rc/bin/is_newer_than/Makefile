# $FreeBSD$

PACKAGE=runtime
PROG=	is_newer_than

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${ORSRC}/rc

SRCS=	is_newer_than.c \
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

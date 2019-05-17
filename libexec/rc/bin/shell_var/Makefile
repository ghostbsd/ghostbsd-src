# $FreeBSD$

PACKAGE=runtime
PROG=	shell_var

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${ORSRC}/rc

SRCS=	shell_var.c
CFLAGS+=	-I${ORSRC}/rc \
		-I${ORSRC}/libeinfo \
		-I${ORSRC}/librc \
                -I${.OBJDIR}/../../../../lib/librc/contrib/openrc/src/librc \
		-I${ORSRC}/includes

WARNS?=	3

BINDIR?=/libexec/rc/bin
LIBADD=	einfo kvm rc util
MAN=

.include <bsd.prog.mk>

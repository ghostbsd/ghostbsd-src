# $FreeBSD$

PACKAGE=runtime
PROG=	get_options

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${ORSRC}/rc

LINKS=  ${BINDIR}/get_options ${BINDIR}/service_get_value \
	${BINDIR}/get_options ${BINDIR}/service_set_value \
	${BINDIR}/get_options ${BINDIR}/save_options
SRCS=	do_value.c \
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

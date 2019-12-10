# $FreeBSD$

PACKAGE=runtime
PROG=	einfo

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${ORSRC}/rc

LINKS=  ${BINDIR}/einfo ${BINDIR}/einfon \
	${BINDIR}/einfo ${BINDIR}/ewarn \
	${BINDIR}/einfo ${BINDIR}/ewarnn \
	${BINDIR}/einfo ${BINDIR}/eerror \
	${BINDIR}/einfo ${BINDIR}/eerrorn \
	${BINDIR}/einfo ${BINDIR}/ebegin \
	${BINDIR}/einfo ${BINDIR}/eend \
	${BINDIR}/einfo ${BINDIR}/ewend \
	${BINDIR}/einfo ${BINDIR}/eindent \
	${BINDIR}/einfo ${BINDIR}/eoutdent \
	${BINDIR}/einfo ${BINDIR}/esyslog \
	${BINDIR}/einfo ${BINDIR}/eval_ecolors \
	${BINDIR}/einfo ${BINDIR}/ewaitfile \
	${BINDIR}/einfo ${BINDIR}/veinfo \
	${BINDIR}/einfo ${BINDIR}/vewarn \
	${BINDIR}/einfo ${BINDIR}/vebegin \
	${BINDIR}/einfo ${BINDIR}/veend \
	${BINDIR}/einfo ${BINDIR}/vewend \
	${BINDIR}/einfo ${BINDIR}/veindent \
	${BINDIR}/einfo ${BINDIR}/veoutdent
SRCS=	do_e.c \
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

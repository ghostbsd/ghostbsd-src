# $FreeBSD$

PACKAGE=lib${LIB}
LIB=		einfo
LIBADD+=	kvm
SHLIBDIR?=	/lib

.include <src.opts.mk>

LIBEINFOSRC=	${SRCTOP}/contrib/openrc/src

.PATH:  ${LIBEINFOSRC}/libeinfo

SHLIB_MAJOR=	1
SHLIB_MINOR=	0
SRCS=		libeinfo.c
INCS=		einfo.h
CFLAGS+=	-D_GNU_SOURCE -I${LIBEINFOSRC}/libeinfo \
		-I${SRCTOP}/contrib/openrc/src/includes

.if defined(HAVE_DEBUG)
CFLAGS+=	-g
CFLAGS+=	-DHAVE_DEBUG
.endif

SYM_MAPS+=      ${LIBEINFOSRC}/libeinfo/einfo.map
SYMBOL_MAPS=    ${SYM_MAPS}

MLINKS=

.include <bsd.lib.mk>

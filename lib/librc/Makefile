# $FreeBSD$
#
GITVER="0.35"
PACKAGE=lib${LIB}
LIB=		rc
SHLIBDIR?=	/lib
SHLIB_MAJOR=	1
SHLIB_MINOR=	0

.include <src.opts.mk>

LIBRCSRC=    ${SRCTOP}/contrib/openrc/src

.PATH:  ${LIBRCSRC}/librc

SRCS=		librc.c \
		librc-daemon.c \
		librc-depend.c \
		librc-misc.c \
		librc-stringlist.c
CFLAGS+=	-D_GNU_SOURCE -I${LIBRCSRC}/libeinfo \
		-I${LIBRCSRC}/rc \
		-I${.OBJDIR}/contrib/openrc/src/librc \
		-I${LIBRCSRC}/includes

rc.h:
	mkdir -p ${.OBJDIR}/contrib/openrc/src/librc
	cp ${LIBRCSRC}/librc/rc.h.in ${.OBJDIR}/contrib/openrc/src/librc/rc.h
	sed -i '' 's|@PREFIX@||g' ${.OBJDIR}/contrib/openrc/src/librc/rc.h
	sed -i '' 's|@LIBEXECDIR@|/libexec/rc|g' ${.OBJDIR}/contrib/openrc/src/librc/rc.h
	sed -i '' 's|@BINDIR@|/usr/local/bin|g' ${.OBJDIR}/contrib/openrc/src/librc/rc.h
	sed -i '' 's|@SBINDIR@|/usr/local/sbin|g' ${.OBJDIR}/contrib/openrc/src/librc/rc.h
	sed -i '' 's|@PKG_PREFIX@|/usr/local|g' ${.OBJDIR}/contrib/openrc/src/librc/rc.h
	sed -i '' 's|@LOCAL_PREFIX@|/usr/local|g' ${.OBJDIR}/contrib/openrc/src/librc/rc.h
	sed -i '' 's|@SYSCONFDIR@|/etc|g' ${.OBJDIR}/contrib/openrc/src/librc/rc.h
	sed -i '' 's|@LIB@|/lib|g' ${.OBJDIR}/contrib/openrc/src/librc/rc.h

version.h:
	mkdir -p ${.OBJDIR}/contrib/openrc/src/librc
	echo "#define VERSION \"${GITVER}\"" >${.OBJDIR}/contrib/openrc/src/librc/version.h

beforedepend: rc.h version.h

.if defined(HAVE_DEBUG)
CFLAGS+=	-g
CFLAGS+=	-DHAVE_DEBUG
.endif
LIBADD+= kvm

SYM_MAPS+=      ${LIBRCSRC}/librc/rc.map
SYMBOL_MAPS=    ${SYM_MAPS}

MLINKS=

.include <bsd.lib.mk>

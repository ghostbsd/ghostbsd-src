# $FreeBSD$

PACKAGE=runtime
PROG=	dhcpcd

.include <src.opts.mk>

ORSRC=    ${SRCTOP}/contrib/dhcpcd/src

.PATH:  ${ORSRC}

SRCS=	common.c control.c dhcpcd.c duid.c eloop.c logerr.c
SRCS+=	if.c if-options.c sa.c route.c dhcp-common.c
SRCS+=	script.c auth.c if-bsd.c dhcp.c ipv4.c bpf.c
SRCS+=	arp.c ipv4ll.c ipv6.c ipv6nd.c dhcp6.c dhcpcd-embedded.c
SRCS+=	../compat/crypt/hmac.c ../compat/pidfile.c ../compat/strtoi.c
SRCS+=	../compat/strtou.c

CSTD?=          c99
CFLAGS+=        -O2 -std=${CSTD} -I${ORSRC} -I${ORSRC}/../ -I${OSRC}../compat -Wno-unused-variable -Wno-unused-label
CFLAGS+=	-DHAVE_CONFIG_H -DNDEBUG -D_GNU_SOURCE -DINET -DARP -DARPING -DIPV4LL -DINET6 -DDHCP6 -DAUTH
CFLAGS+=	-lmd
CPPFLAGS+=      -I${ORSRC} -I${ORSRC}/../ -I./crypt

WARNS?=	1
MAN=	${ORSRC}/dhcpcd.conf.5
MAN+=	${ORSRC}/dhcpcd.8

CONFS=		dhcpcd.conf
CONFDIR=	/etc
CONFMODE=	644

.include <bsd.prog.mk>

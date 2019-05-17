# $FreeBSD$
#
#

SHSRC=    ${SRCTOP}/contrib/dhcpcd

.PATH:  ${SHSRC}/hooks

FILES+=	01-test \
	02-dump \
	20-resolv.conf \
	30-hostname

FILESDIR=       /libexec/dhcpcd-hooks
FILESMODE=      755

.include <bsd.prog.mk>

/* freebsd */
#define SYSCONFDIR	"/etc"
#define SBINDIR		"/sbin"
#define LIBDIR		"/lib"
#define LIBEXECDIR	"/libexec"
#define DBDIR		"/var/db/dhcpcd"
#define RUNDIR		"/var/run"
#include		<net/if.h>
#include		<net/if_var.h>
#include		"compat/pidfile.h"
#include		"compat/strtoi.h"
#define HAVE_SYS_QUEUE_H
#define HAVE_REALLOCARRAY
#define HAVE_KQUEUE
#define HAVE_MD5_H
#define SHA2_H		<sha256.h>
#include		"compat/crypt/hmac.h"

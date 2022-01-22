/*-
 * SPDX-License-Identifier: BSD-2-Clause-FreeBSD
 *
 * Copyright (c) 2011 Nathan Whitehorn
 * Copyright (c) 2014 Devin Teske <dteske@FreeBSD.org>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/cdefs.h>
__FBSDID("$FreeBSD$");

#include <sys/param.h>
#include <archive.h>
#include <ctype.h>
#include <bsddialog.h>
#include <bsddialog_progressview.h>
#include <err.h>
#include <errno.h>
#include <limits.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* Data to process */
static char *distdir = NULL;
static struct archive *archive = NULL;

/* Function prototypes */
static void	sig_int(int sig);
static int	count_files(const char *file);
static int	extract_files(struct bsddialog_fileminibar *file);

#define _errx(...) (bsddialog_end(), errx(__VA_ARGS__))

int
main(void)
{
	char *chrootdir;
	char *distributions;
	unsigned int i;
	int retval;
	size_t minibar_size = sizeof(struct bsddialog_fileminibar);
	size_t span;
	unsigned int nminibars;
	struct bsddialog_fileminibar *dists;
	struct bsddialog_progviewconf pvconf;
	struct bsddialog_conf conf;
	struct sigaction act;
	char error[PATH_MAX + 512];

	if ((distributions = getenv("DISTRIBUTIONS")) == NULL)
		errx(EXIT_FAILURE, "DISTRIBUTIONS variable is not set");
	if ((distdir = getenv("BSDINSTALL_DISTDIR")) == NULL)
		distdir = __DECONST(char *, "");

	if (bsddialog_init() == BSDDIALOG_ERROR)
		errx(EXIT_FAILURE, "Cannot init libbsdialog");
	bsddialog_initconf(&conf);
	bsddialog_backtitle(&conf, __DECONST(char *, "FreeBSD Installer"));
	bsddialog_infobox(&conf,
	    __DECONST(char *, "Checking distribution archives.\n"
	    "Please wait..."), 4, 35);

	/* Parse $DISTRIBUTIONS */
	nminibars = 0;
	dists = NULL;
	while (*distributions != '\0') {
		span = strcspn(distributions, "\t\n\v\f\r ");
		if (span < 1) { /* currently on whitespace */
			distributions++;
			continue;
		}

		/* Allocate a new struct for the distribution */
		dists = realloc(dists, (nminibars + 1) * minibar_size);
		if (dists == NULL)
			_errx(EXIT_FAILURE, "Out of memory!");

		/* Set file path */
		if ((dists[nminibars].path = malloc(span + 1)) == NULL)
			_errx(EXIT_FAILURE, "Out of memory!");
		snprintf(dists[nminibars].path, span + 1, "%s", distributions);
		dists[nminibars].path[span] = '\0';

		/* Set mini bar label */
		dists[nminibars].label = strrchr(dists[nminibars].path, '/');
		if (dists[nminibars].label == NULL)
			dists[nminibars].label = dists[nminibars].path;

		/* Set initial length in files (-1 == error) */
		dists[nminibars].size = count_files(dists[nminibars].path);
		if (dists[nminibars].size < 0) {
			bsddialog_end();
			return (EXIT_FAILURE);
		}

		/* Set initial status to pending */
		/* dists[nminibars].status = 10; */

		/* Set initial read */
		dists[nminibars].read = 0;

		distributions += span;
		nminibars += 1;
	}

	/* Optionally chdir(2) into $BSDINSTALL_CHROOT */
	chrootdir = getenv("BSDINSTALL_CHROOT");
	if (chrootdir != NULL && chdir(chrootdir) != 0) {
		snprintf(error, sizeof(error),
		    "Could not change to directory %s: %s\n",
		    chrootdir, strerror(errno));
		conf.title = __DECONST(char *, "Error");
		bsddialog_msgbox(&conf, error, 0, 0);
		bsddialog_end();
		return (EXIT_FAILURE);
	}

	/* Set cleanup routine for Ctrl-C action */
	act.sa_handler = sig_int;
	sigaction(SIGINT, &act, 0);

	conf.title = __DECONST(char *, "Archive Extraction");
	pvconf.callback	= extract_files;
	pvconf.refresh = 1;
	pvconf.fmtbottomstr = __DECONST(char *, "%10lli files read @ %'9.1f files/sec.");
	bsddialog_total_progview = 0;
	bsddialog_interruptprogview = bsddialog_abortprogview = false;
	retval = bsddialog_progressview(&conf,
	    __DECONST(char *, "Extracting distribution files..."), 0, 0, &pvconf, nminibars, dists);

	bsddialog_end();

	for (i=0; i<nminibars; i++) {
		if (dists[i].path != NULL)
			free(dists[i].path);
	}
	if (dists != NULL)
		free(dists);

	return (retval);
}

static void
sig_int(int sig __unused)
{
	bsddialog_interruptprogview = true;
}

/*
 * Returns number of files in archive file. Parses $BSDINSTALL_DISTDIR/MANIFEST
 * if it exists, otherwise uses archive(3) to read the archive file.
 */
static int
count_files(const char *file)
{
	static FILE *manifest = NULL;
	char *p;
	int file_count;
	int retval;
	size_t span;
	struct archive_entry *entry;
	char line[512];
	char path[PATH_MAX];
	char errormsg[PATH_MAX + 512];
	struct bsddialog_conf conf;

	if (manifest == NULL) {
		snprintf(path, sizeof(path), "%s/MANIFEST", distdir);
		manifest = fopen(path, "r");
	}

	if (manifest != NULL) {
		rewind(manifest);
		while (fgets(line, sizeof(line), manifest) != NULL) {
			p = &line[0];
			span = strcspn(p, "\t") ;
			if (span < 1 || strncmp(p, file, span) != 0)
				continue;

			/*
			 * We're at the right manifest line. The file count is
			 * in the third element
			 */
			span = strcspn(p += span + (*p != '\0' ? 1 : 0), "\t");
			span = strcspn(p += span + (*p != '\0' ? 1 : 0), "\t");
			if (span > 0) {
				file_count = (int)strtol(p, (char **)NULL, 10);
				if (file_count == 0 && errno == EINVAL)
					continue;
				return (file_count);
			}
		}
	}

	/*
	 * Either no manifest, or manifest didn't mention this archive.
	 * Use archive(3) to read the archive, counting files within.
	 */
	bsddialog_initconf(&conf);
	if ((archive = archive_read_new()) == NULL) {
		snprintf(errormsg, sizeof(errormsg),
		    "Error: %s\n", archive_error_string(NULL));
		conf.title = __DECONST(char *, "Extract Error");
		bsddialog_msgbox(&conf, errormsg, 0, 0);
		return (-1);
	}
	archive_read_support_format_all(archive);
	archive_read_support_filter_all(archive);
	snprintf(path, sizeof(path), "%s/%s", distdir, file);
	retval = archive_read_open_filename(archive, path, 4096);
	if (retval != ARCHIVE_OK) {
		snprintf(errormsg, sizeof(errormsg),
		    "Error while extracting %s: %s\n", file,
		    archive_error_string(archive));
		conf.title = __DECONST(char *, "Extract Error");
		bsddialog_msgbox(&conf, errormsg, 0, 0);
		archive = NULL;
		return (-1);
	}

	file_count = 0;
	while (archive_read_next_header(archive, &entry) == ARCHIVE_OK)
		file_count++;
	archive_read_free(archive);
	archive = NULL;

	return (file_count);
}

static int
extract_files(struct bsddialog_fileminibar *file)
{
	int retval;
	struct archive_entry *entry;
	char path[PATH_MAX];
	char errormsg[PATH_MAX + 512];
	struct bsddialog_conf conf;

	bsddialog_initconf(&conf);

	/* Open the archive if necessary */
	if (archive == NULL) {
		if ((archive = archive_read_new()) == NULL) {
			snprintf(errormsg, sizeof(errormsg),
			    "Error: %s\n", archive_error_string(NULL));
			conf.title = __DECONST(char *, "Extract Error");
			bsddialog_msgbox(&conf, errormsg, 0, 0);
			bsddialog_abortprogview = true;
			return (-1);
		}
		archive_read_support_format_all(archive);
		archive_read_support_filter_all(archive);
		snprintf(path, sizeof(path), "%s/%s", distdir, file->path);
		retval = archive_read_open_filename(archive, path, 4096);
		if (retval != 0) {
			snprintf(errormsg, sizeof(errormsg),
			    "Error opening %s: %s\n", file->label,
			    archive_error_string(archive));
			conf.title = __DECONST(char *, "Extract Error");
			bsddialog_msgbox(&conf, errormsg, 0, 0);
			file->status = 1; /* Failed */
			bsddialog_abortprogview = true;
			return (-1);
		}
	}

	/* Read the next archive header */
	retval = archive_read_next_header(archive, &entry);

	/* If that went well, perform the extraction */
	if (retval == ARCHIVE_OK)
		retval = archive_read_extract(archive, entry,
		    ARCHIVE_EXTRACT_TIME | ARCHIVE_EXTRACT_OWNER |
		    ARCHIVE_EXTRACT_PERM | ARCHIVE_EXTRACT_ACL |
		    ARCHIVE_EXTRACT_XATTR | ARCHIVE_EXTRACT_FFLAGS);

	/* Test for either EOF or error */
	if (retval == ARCHIVE_EOF) {
		archive_read_free(archive);
		archive = NULL;
		file->status = 5; /*Done*/;
		return (100);
	} else if (retval != ARCHIVE_OK &&
	    !(retval == ARCHIVE_WARN &&
	    strcmp(archive_error_string(archive), "Can't restore time") == 0)) {
		/*
		 * Print any warning/error messages except inability to set
		 * ctime/mtime, which is not fatal, or even interesting,
		 * for our purposes. Would be nice if this were a libarchive
		 * option.
		 */
		snprintf(errormsg, sizeof(errormsg),
		    "Error while extracting %s: %s\n", file->label,
		    archive_error_string(archive));
		conf.title = __DECONST(char *, "Extract Error");
		bsddialog_msgbox(&conf, errormsg, 0, 0);
		file->status = 1; /* Failed */
		bsddialog_abortprogview = true;
		return (-1);
	}

	bsddialog_total_progview++;
	file->read++;

	/* Calculate [overall] percentage of completion (if possible) */
	if (file->size >= 0)
		return (file->read * 100 / file->size);
	else
		return (-1);
}

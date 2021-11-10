#!/bin/sh
#-
# Copyright (c) 2021 GhostBSD
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

set -e

progname=${0##*/}

error() {
  echo "$progname: $*" >&2
  exit 1
}

kernel_version() {
  uname -K
}

ghostbsd_version() {
  if [ -f "/etc/version" ] ; then
    version=$(cat /etc/version)
    printf "%s\n" "$version"
  else
    pkg query '%v' os-generic-userland-base
  fi
}

freebsd_version() {
  uname -r
}

os_version() {
  pkg query '%v' os-generic-userland-base
}

usage() {
  echo "usage: $progname [-fkov]" >&2
  exit 1
}


main() {
  # parse command-line arguments
  local OPTIND=1 OPTARG option
  while getopts "fkov" option ; do
    case $option in
    f)
      opt_f=1
      freebsd_version
      ;;
    k)
      opt_k=1
      kernel_version
      ;;
    o)
      opt_o=1
      os_version
      ;;
    v)
      opt_v=1
      ghostbsd_version
      ;;
    *)
      usage
      ;;
    esac
  done
  if [ $OPTIND -le $# ] ; then
    usage
  fi

  # default is -v
  if [ $((opt_f + opt_k + opt_o + opt_v)) -eq 0 ] ; then
    ghostbsd_version
  fi
}

main "$@"

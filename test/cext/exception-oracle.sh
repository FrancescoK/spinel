#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
tmp=$(mktemp -d "${TMPDIR:-/tmp}/spinel-cext-oracle.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
cp test/cext/exception-api.c "$tmp/cext_exception_oracle.c"
cd "$tmp"
ruby -rmkmf -e '$defs << "-DSP_CEXT_ORACLE"; create_makefile("cext_exception_oracle")' > build.log 2>&1
make >> build.log 2>&1 || { cat build.log; exit 1; }
ruby -I. -rcext_exception_oracle -e 'puts "cext-exceptions-oracle: pass"'

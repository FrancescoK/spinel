#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
root=$PWD
tmp=$(mktemp -d "${TMPDIR:-/tmp}/spinel-cext-record-oracle.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
ruby tools/cext-record.rb --name sample --init Init_sample --output "$tmp/manifest.json" test/cext/recorder/definitions.c
cp test/cext/recorder/definitions.c "$tmp/sample.c"
cd "$tmp"
ruby -rmkmf -e 'create_makefile("sample")' > build.log 2>&1
make >> build.log 2>&1 || { cat build.log; exit 1; }
ruby -I. -rsample "$root/test/cext/recorder-oracle.rb" "$tmp/manifest.json"

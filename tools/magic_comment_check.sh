#!/bin/sh
# Magic comments, read from each file's own Prism parse (#9898): a source
# encoding other than UTF-8 warns at its file and line that the file's
# literals take UTF-8 as their encoding, in a required file as in the entry; a `frozen_string_literal: false` pragma
# warns at its file and line and is ignored; prose that only mentions the
# pragma is not one.
# Both programs still compile; make test checks what they print.
SPINEL=${SPINEL:-bin/spinel}
tmp=$(mktemp -d "${TMPDIR:-/tmp}/spinel-magic.XXXXXX") || exit 2
trap 'rm -rf "$tmp"' EXIT
ok=1
fail() { echo "magic-comment-test: FAIL ($1)"; ok=0; }

t=test/source_encoding_magic_comment.rb
if "$SPINEL" "$t" -c --no-line-map -o "$tmp/e.c" >"$tmp/e.out" 2>&1; then
  grep -qF "spinel: test/source_encoding_magic_comment/sjis.rb:1: warning: source encoding Shift_JIS: Spinel's Strings are UTF-8, so this file's literals keep the bytes they are written with but take UTF-8 as their encoding" "$tmp/e.out" ||
    fail "no warning naming the Shift_JIS comment's file and line"
  [ "$(grep -c 'warning: source encoding' "$tmp/e.out")" = 1 ] ||
    { fail "expected one encoding warning (the utf-8 comments warn nothing)"; cat "$tmp/e.out"; }
else
  fail "$t did not compile"; sed -n 1,5p "$tmp/e.out"
fi

t=test/frozen_string_literal_per_file.rb
if "$SPINEL" "$t" -c --no-line-map -o "$tmp/f.c" >"$tmp/f.out" 2>&1; then
  grep -qF "spinel: test/frozen_string_literal_per_file/helper_plain.rb:1: warning: frozen_string_literal: false is not supported in Spinel" "$tmp/f.out" ||
    fail "no pragma warning naming helper_plain.rb's file and line"
  [ "$(grep -c 'warning: frozen_string_literal: false is not supported' "$tmp/f.out")" = 1 ] ||
    { fail "expected one pragma warning, for helper_plain.rb"; cat "$tmp/f.out"; }
else
  fail "$t did not compile"; sed -n 1,5p "$tmp/f.out"
fi

[ $ok -eq 1 ] && echo "magic-comment-test: pass" || exit 1

#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
tmp=$(mktemp -d "${TMPDIR:-/tmp}/spinel-cext-header.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
${CC:-cc} -std=c11 -Wall -Wextra -Werror -fsanitize=undefined -Iinclude test/cext/immediates.c -o "$tmp/immediates"
"$tmp/immediates"
for api in RBASIC ROBJECT RSTRUCT; do
    printf '#include <ruby.h>\nint main(void) { return %s(Qnil) != 0; }\n' "$api" > "$tmp/refuse.c"
    if ${CC:-cc} -O2 -Iinclude -c "$tmp/refuse.c" -o "$tmp/refuse.o" > "$tmp/error" 2>&1; then
        echo "cext-header-test: FAIL ($api accepted)"; exit 1
    fi
    grep -q "CRuby object layout is not provided" "$tmp/error"
done
printf '#include <ruby.h>\nint main(void) { return (int)rb_eval_string("1"); }\n' > "$tmp/refuse.c"
if ${CC:-cc} -O2 -Iinclude -c "$tmp/refuse.c" -o "$tmp/refuse.o" > "$tmp/error" 2>&1; then
    echo 'cext-header-test: FAIL (eval accepted)'; exit 1
fi
grep -q 'Ruby eval requires' "$tmp/error"
echo 'cext-header-test: pass'

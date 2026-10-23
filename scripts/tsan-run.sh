#!/bin/bash
# tsan-run.sh -- compile and run a threaded spinel program under ThreadSanitizer.
#
# The normal test gate links a threaded test against the threaded runtime, as
# the driver does, but uninstrumented: a data race there only shows when it
# happens to corrupt the output. This drives a program through the threaded
# runtime instrumented with TSan, so a data race on the
# shared GC heap, the thread registry, or the run queue is reported instead of
# silently corrupting memory. This is the Phase 1 (N>1) validation gate.
#
# Usage: scripts/tsan-run.sh prog.rb [prog args...]
#   SPINEL=path/to/spinel  to override the compiler binary
#   SPINEL_WORKERS=N       to set the worker count (once N>1 lands)
set -euo pipefail

# --spin DIR drives a whole spin APPLICATION through this, not just a lone .rb:
# `spin flags` in DIR prints exactly the flags `spin build` would pass (the
# package include paths, the require gate, and the native objects it has
# already compiled), so the program under TSan is the one the application
# really builds. The --link operands are for the LINK line, not for `-S`, so
# they are split back out below.
#
#   scripts/tsan-run.sh --spin path/to/app path/to/app/bin/app.rb
#
# A race inside a C library the application binds (SQLite, say) is reported
# against the thread that entered it, which is what makes this worth having:
# the runtime's own parallelism and the library's meet in one report.
spin_dir=""
if [ "${1:-}" = "--spin" ]; then
  spin_dir="${2:?usage: tsan-run.sh --spin DIR prog.rb [args...]}"; shift 2
fi

rb="${1:?usage: tsan-run.sh [--spin DIR] prog.rb [args...]}"; shift || true
SPINEL="${SPINEL:-bin/spinel}"
ARCHIVE="lib/libspinel_rt_mt_tsan.a"

# Flags for the compiler, and the objects for the link line, kept apart.
sp_flags=""
link_objs=""
if [ -n "$spin_dir" ]; then
  raw="$( cd "$spin_dir" && spin flags )" || {
    echo "tsan-run: 'spin flags' failed in $spin_dir" >&2; exit 2; }
  take_next=0
  for tok in $raw; do
    if [ "$take_next" = 1 ]; then link_objs="$link_objs $tok"; take_next=0; continue; fi
    case "$tok" in
      --link) take_next=1 ;;
      *) sp_flags="$sp_flags $tok" ;;
    esac
  done
fi

if [ ! -f "$ARCHIVE" ]; then
  echo "tsan-run: $ARCHIVE missing -- run 'make tsan-archive' first" >&2
  exit 2
fi

c="$(mktemp /tmp/tsan-run-XXXXXX.c)"
bin="$(mktemp /tmp/tsan-run-XXXXXX.bin)"
trap 'rm -f "$c" "$bin"' EXIT

"$SPINEL" $sp_flags "$rb" -S > "$c"

# The spinel driver adds two things to its own link line that no flag string
# carries, because both are read out of the generated C: the libraries an
# ffi_lib declared, and the bundled package objects a require pulled in. A
# program that binds a library or uses a bundled package -- which is every
# application -- did not link here without them (#4315).
ffi_libs="$(sed -n 's#^.*/\* SPINEL_LINK: \(.*\) \*/.*$#\1#p' "$c" | tr '\n' ' ')"
pkg_objs=""
for o in $(sed -n 's#^.*/\* SPINEL_LINK_OBJ: \(.*\) \*/.*$#\1#p' "$c"); do
  # This build is always -DSP_THREADS, so take the _mt variant: a package
  # object built without it names the runtime's per-worker globals as non-TLS
  # and the link fails.
  mt="${o%.o}_mt.o"
  cand=""
  for p in "$mt" "$o"; do
    for base in "." ".."; do
      [ -f "$base/$p" ] && { cand="$base/$p"; break 2; }
    done
  done
  [ -n "$cand" ] || { echo "tsan-run: cannot find $o (build it first)" >&2; exit 2; }
  # Skip one spin already put on the line: the same object under both names is
  # a multiple definition. Compare basenames with the _mt marker removed, the
  # way the driver does.
  cb="$(basename "$cand" | sed 's/_mt\.o$/.o/')"
  dup=0
  for l in $link_objs; do
    [ "$(basename "$l" | sed 's/_mt\.o$/.o/')" = "$cb" ] && dup=1
  done
  [ "$dup" = 1 ] || pkg_objs="$pkg_objs $cand"
done
# The host libraries, as the driver's add_host_libs (src/main.c) picks them:
# String#crypt is libc crypt(3), which Darwin's and OpenBSD's libc carry with
# no libcrypt to link, and OpenBSD's backtrace(3) is libexecinfo's.
host_libs=""
case "$(uname)" in
  Darwin) ;;
  OpenBSD) host_libs="-lexecinfo" ;;
  *) if grep -q 'sp_str_crypt(' "$c"; then host_libs="-lcrypt"; fi ;;
esac
# -Wno-all matches the production cc driver (src/main.c): the generated C
# carries benign patterns (e.g. a fiber body's dead deferred-return epilogue)
# that newer clangs otherwise reject by default.
cc -O1 -g -Wno-all -fsanitize=thread -DSP_THREADS -ftls-model=initial-exec \
   -Ilib -Ilib/regexp "$c" $link_objs $pkg_objs "$ARCHIVE" -lm $host_libs -lpthread $ffi_libs -o "$bin"

# halt_on_error keeps the first race fatal (a clean exit means TSan saw none).
TSAN_OPTIONS="halt_on_error=1 ${TSAN_OPTIONS:-}" "$bin" "$@"

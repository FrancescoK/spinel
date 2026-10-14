#!/bin/bash
# race-check.sh -- run a threaded spinel program under a data-race detector.
#
# The normal test gate links a threaded test against the threaded runtime, as
# the driver does, but uninstrumented: a data race there only shows when it
# happens to corrupt the output. This compiles the program through
# the real spinel driver (so it links the threaded runtime, libspinel_rt_mt.a,
# plus -lpthread) and runs it under Valgrind/Helgrind, which reports any data
# race on the shared GC heap, the thread registry, or the run queue. This is the
# Phase 1 (N>1) validation gate.
#
# Helgrind, not ThreadSanitizer: TSan reserves fixed virtual-address ranges for
# its shadow memory and FATALs ("unexpected memory mapping") on the fiber stacks
# that the green-thread scheduler mmaps -- the per-fiber __tsan_switch_to_fiber
# instrumentation in sp_fiber.c handles the cooperative switch, but not the stack
# placement. Helgrind instruments dynamically and has no such range restriction,
# so it runs the fiber program directly. (TSan can be revisited once fiber stacks
# are allocated in a TSan-tolerated range; the tsan-archive target still builds.)
#
# Usage: scripts/race-check.sh prog.rb [prog args...]
#   SPINEL=path/to/spinel  to override the compiler binary
#   SPINEL_WORKERS=N       to set the worker count (once N>1 lands)
set -euo pipefail

rb="${1:?usage: race-check.sh prog.rb [args...]}"; shift || true
SPINEL="${SPINEL:-bin/spinel}"

if ! command -v valgrind >/dev/null 2>&1; then
  echo "race-check: valgrind not found" >&2
  exit 2
fi

bin="$(mktemp /tmp/race-check-XXXXXX.bin)"
trap 'rm -f "$bin"' EXIT

"$SPINEL" "$rb" -o "$bin"

# --error-exitcode=99 makes a detected race fail the script; a clean exit (and
# "0 errors" summary) means Helgrind saw none.
exec valgrind --tool=helgrind --error-exitcode=99 \
     --gen-suppressions=no "$bin" "$@"

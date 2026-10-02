#!/usr/bin/env bash
# usage: gate-leg.sh CHECKOUT OUT [prepare|run|all]
# CHECKOUT is a scratch clone at the item's HEAD. Local smoke tests may set
# GATE_TARGET=infer-test and GATE_JOBS=8; CI defaults to gate and nproc.
set -euo pipefail
checkout=$1
mkdir -p "$2"
out=$(cd "$2" && pwd)
phase=${3:-all}
cd "$checkout"
master=unknown
merged=unknown
merge_base=unknown
status=FAIL
rc=1
write_meta() {
    printf 'master=%s\nmerged=%s\nmerge_base=%s\nstatus=%s\nexit_status=%s\ntarget=%s\n' \
        "$master" "$merged" "$merge_base" "$status" "$rc" "${GATE_TARGET:-gate}" > "$out/gate-meta.txt"
}
# Called by the EXIT trap.
# shellcheck disable=SC2329
finish() {
    result=$?
    if [ "$result" -ne 0 ]; then rc=$result; status=FAIL; fi
    write_meta
}
trap finish EXIT
if [ "$phase" != run ]; then
    : > "$out/gate.log"
    : > "$out/gate-summary.txt"
    echo "gate ${NAME:-local} 0 $(git log -1 --format='%h %s')" > "$out/rev.txt"
    git fetch https://github.com/matz/spinel.git master >> "$out/gate.log" 2>&1
    master=$(git rev-parse FETCH_HEAD)
    merge_base=$(git merge-base HEAD "$master")
    # Detached checkouts still need an identity to create the merge commit.
    git config user.name 'verify gate'
    git config user.email 'verify-gate@users.noreply.github.com'
    if git merge --no-edit "$master" >> "$out/gate.log" 2>&1; then
        merged=$(git rev-parse HEAD)
    else
        rc=$?
        if [ -n "$(git diff --name-only --diff-filter=U)" ]; then
            status=CONFLICT
            { echo 'GATE: CONFLICT'; git diff --name-only --diff-filter=U; } | tee "$out/gate-summary.txt"
            cat "$out/gate-summary.txt" >> "$out/gate.log"
            exit 0
        fi
        exit "$rc"
    fi
    status=PREPARED
    rc=0
    write_meta
    [ "$phase" != prepare ] || exit 0
else
    # The workflow restores vendor/ between prepare and run.
    master=$(sed -n 's/^master=//p' "$out/gate-meta.txt")
    merged=$(sed -n 's/^merged=//p' "$out/gate-meta.txt")
    merge_base=$(sed -n 's/^merge_base=//p' "$out/gate-meta.txt")
fi
status=FAIL
rc=1
make deps >> "$out/gate.log" 2>&1 || { sleep 30; make deps >> "$out/gate.log" 2>&1; }
# Preserve make's status, even though its output passes through tee.
set +e
RUBYSPEC_JOBS=${GATE_JOBS:-$(nproc)} make -j"${GATE_JOBS:-$(nproc)}" "${GATE_TARGET:-gate}" 2>&1 | tee -a "$out/gate.log"
rc=${PIPESTATUS[0]}
set -e
grep -E 'Tests:|scale-test|gate:' "$out/gate.log" > "$out/gate-summary.txt" || true
[ "$rc" -ne 0 ] || status=PASS
exit "$rc"

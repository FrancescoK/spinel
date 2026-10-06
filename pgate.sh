#!/usr/bin/env bash
# The parallel gate's (pgate) steps on one runner; pgate.py has the split
# and the reasoning.
#
# usage: pgate.sh prep CHECKOUT OUT
#   after `gate-leg.sh CHECKOUT OUT prepare` merged current master: hold the
#   tree to the split (pgate.py check), `make deps`, gate.rb start and the
#   gate's `make all $(SPINEL_TIMEOUT)`, then record what finish checks
#   against (the start tree, the corpus size, the rubyspec suites, CC) in
#   OUT/gate-meta.txt, and the corpus PCH's cache key in OUT/pch.txt.
# usage: pgate.sh pch CHECKOUT OUT HIT
#   build the corpus's precompiled headers (gate-test's OPT=-O1) the way the
#   corpus would. HIT=true: they were restored from the cache under their
#   inputs' key, so they are made newer than the headers first and make
#   leaves them be.
# usage: pgate.sh part PREP OUT PART K N
#   PREP is the prep job's artifact (gate-meta.txt, tree.tar.zst); the tree
#   unpacks under PGATE_ROOT (default RUNNER_TEMP), at the path it was built.
#   PART is legs, corpus (K of N) or rubyspec (K of N). OUT gets part.txt
#   (rc, the tree after the run, the command, seconds, cache use),
#   part.log, result-cache.tar and, for corpus, test-results.tar.
# usage: pgate.sh cdiff PREP OUT CACHE
#   the corpus C diff of the merged tree against the master it merged
#   (gate-meta.txt's master=), in the verify workflow's cdiff leg's files:
#   the tree unpacks as for a part, the master is checked out beside it
#   ($PGATE_ROOT/base, a worktree of the tree's clone) and built, and
#   cdiff-leg.sh compares the two, the base's C from CACHE where it stands.
#   Not a part of the gate: finish neither waits on it nor reads it.
# GATE_JOBS overrides the job count (default nproc), as in gate-leg.sh.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
cmd=$1
jobs=${GATE_JOBS:-$(nproc 2>/dev/null || sysctl -n hw.ncpu)}
tmp=$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/pgate.XXXXXX")
trap 'rm -rf "$tmp"' EXIT

# mkvar [VAR=VALUE...] NAME...: make variables of the tree in the current
# directory as make computes them, one per line.
mkvar() {
    # shellcheck disable=SC2016
    printf 'include Makefile\npgate-print-%%:\n\t@echo $($*)\n' > "$tmp/print.mk"
    local a=()
    for w in "$@"; do case "$w" in *=*) a+=("$w") ;; *) a+=("pgate-print-$w") ;; esac; done
    # one target at a time and -j1: under an inherited -j, make runs the print targets in parallel and their
    # output interleaves mid-word
    for t in "${a[@]}"; do case "$t" in *=*) continue ;; esac
        env -u TEST_SHARD -u MAKEFLAGS make -j1 -s --no-print-directory -f "$tmp/print.mk" $(printf '%s\n' "${a[@]}" | grep = ) "$t"
    done
}

# gate.rb's own tree of the working directory (what start records and stamp
# compares), or nothing without a Ruby 4.0.
tree() {
    r=$(sh tools/gate-ruby) && "$r" -e 'require "./tools/gate"; print Gate.worktree_tree' 2>/dev/null || true
}

setmeta() {
    grep -v "^$1=" "$out/gate-meta.txt" > "$tmp/meta" || true
    echo "$1=$2" >> "$tmp/meta"
    cat "$tmp/meta" > "$out/gate-meta.txt"
}

# count DIR GLOB: the files in DIR whose names match GLOB
count() { { find "$1" -type f -name "$2" ! -name '.tmp.*' 2>/dev/null || true; } | wc -l | tr -d ' '; }
entries() { count build/result-cache '*'; }

case "$cmd" in
prep)
    checkout=$2
    out=$(cd "$3" && pwd)
    log="$out/gate.log"
    cd "$checkout"
    master=$(sed -n 's/^master=//p' "$out/gate-meta.txt")
    setmeta status FAIL
    setmeta exit_status 1
    python3 "$here/pgate.py" check . >> "$log" 2>&1
    make deps >> "$log" 2>&1 || { sleep 30; make deps >> "$log" 2>&1; }
    # the gate recipe's first two steps, on the master that was merged
    { r=$(sh tools/gate-ruby) && GATE_MASTER=$master "$r" tools/gate.rb start || true; } >> "$log" 2>&1
    set +e
    make -j"$jobs" --no-print-directory all "$(mkvar SPINEL_TIMEOUT)" >> "$log" 2>&1
    rc=$?
    set -e
    if [ "$rc" -ne 0 ]; then
        echo "[pgate] make all failed (exit $rc)" >> "$log"
        setmeta exit_status "$rc"
        exit "$rc"
    fi
    setmeta start "$(cat "$(git rev-parse --git-dir)/gate-start" 2>/dev/null || true)"
    setmeta ntests "$(mkvar TEST_TARGETS PKG_TEST_TARGETS | wc -w | tr -d ' ')"
    # the target names too, so finish can tell a missing program from an extra .ok
    mkvar TEST_TARGETS PKG_TEST_TARGETS | tr ' ' '\n' | sed '/^$/d' > "$out/targets.txt"
    setmeta rubyspec_suites "$(mkvar RUBYSPEC_SUITES | tr '\n' ' ')"
    setmeta cc "$(mkvar CC)"
    # The PCH's inputs: every header (the fingerprint's own set), the flags
    # and paths it is built with, the Makefile's PCH lines, the compiler and
    # the machine. A .gch is not byte-reproducible (gcc 13 writes a
    # different file each time), and the result cache's fingerprint hashes
    # it, so a rebuilt one would miss every entry of an earlier run.
    {
        mkvar OPT=-O1 PCH_ROOT PCH_FLAGS PCH_PLAIN PCH_NOPOLY
        grep -h PCH Makefile common.mk
        find lib packages -type f \( -name '*.h' -o -name '*.inc' -o -name '*.def' \) | LC_ALL=C sort | xargs sha256sum
        cc --version; uname -sm; echo "${ImageOS:-} ${ImageVersion:-}"
    } | sha256sum | cut -c1-32 > "$tmp/key"
    printf 'key=%s\ndir=%s\n' "$(cat "$tmp/key")" "$(mkvar OPT=-O1 PCH_ROOT)" > "$out/pch.txt"
    setmeta exit_status 0
    setmeta status PREPARED
    ;;
pch)
    checkout=$2
    out=$(cd "$3" && pwd)
    cd "$checkout"
    pchs=$(mkvar OPT=-O1 PCH_PLAIN PCH_NOPOLY | tr '\n' ' ')
    if [ "$4" = true ]; then
        # shellcheck disable=SC2086
        for f in $pchs; do touch "$(dirname "$f")"/*; done
    fi
    set +e
    # shellcheck disable=SC2086
    make -j"$jobs" --no-print-directory OPT=-O1 $pchs >> "$out/gate.log" 2>&1
    rc=$?
    set -e
    echo "[pgate] corpus PCH ($pchs): $([ "$4" = true ] && echo "from the cache" || echo built), exit $rc" >> "$out/gate.log"
    if [ "$rc" -ne 0 ]; then setmeta status FAIL; setmeta exit_status "$rc"; exit "$rc"; fi
    ;;
part)
    prep=$(cd "$2" && pwd)
    mkdir -p "$3"
    out=$(cd "$3" && pwd)
    part=$4 k=$5 n=$6
    log="$out/part.log"
    : > "$log"
    status=$(sed -n 's/^status=//p' "$prep/gate-meta.txt" 2>/dev/null || true)
    if [ "$status" != PREPARED ] || [ ! -f "$prep/tree.tar.zst" ]; then
        # a conflict, or a prep that failed: finish reports it from the prep
        echo "[pgate] no tree to run on (prep status: ${status:-missing})" | tee -a "$log"
        printf 'part=%s\nk=%s\nn=%s\nrc=skipped\n' "$part" "$k" "$n" > "$out/part.txt"
        exit 0
    fi
    root=${PGATE_ROOT:-$RUNNER_TEMP}
    zstd -q -dc "$prep/tree.tar.zst" | tar -C "$root" -xf -
    cd "$root/pgate"
    before=$(entries)
    t0=$(date +%s)
    rc=0
    cmds=""
    run() {
        echo "+ $*" >> "$log"
        set +e
        "$@" 2>&1 | tee -a "$log"
        local r=${PIPESTATUS[0]}
        set -e
        [ "$r" -eq 0 ] || [ "$rc" -ne 0 ] || rc=$r
        cmds="${cmds:+$cmds; }$*"
    }
    case "$part" in
    legs)
        # every leg of the gate, the corpus and the ruby/spec suites taken
        # out (they are the other parts), under one job server as the gate
        # runs them
        run make -j"$jobs" --no-print-directory gate-legs TESTS= PKG_TESTS= RUBYSPEC_SUITES=
        ;;
    corpus)
        run make -j"$jobs" --no-print-directory test-corpus TEST_SHARD="$k/$n" OPT=-O1
        if [ -d build/test-results ]; then tar -C build -cf "$out/test-results.tar" test-results; fi
        ;;
    rubyspec)
        # shellcheck disable=SC2046
        suites=$(python3 "$here/pgate.py" group . "$k" "$n" $(mkvar RUBYSPEC_SUITES))
        if [ -z "$suites" ]; then
            echo "[pgate] rubyspec group $k of $n holds no suite" | tee -a "$log"
            cmds="(none)"
        else
            # run.sh reads RUBYSPEC_JOBS, as gate-leg.sh sets it
            RUBYSPEC_JOBS=$jobs run make -j"$jobs" --no-print-directory gate-rubyspec RUBYSPEC_SUITES="$suites"
        fi
        ;;
    *)
        echo "[pgate] unknown part $part" | tee -a "$log"
        rc=2
        ;;
    esac
    secs=$(( $(date +%s) - t0 ))
    cache="result cache $before entries, $(( $(entries) - before )) new"
    if [ "$part" = corpus ]; then
        cache="$cache, $(count build/test-results '*.ok.cached') of $(count build/test-results '*.ok') programs reused"
    fi
    if [ -d build/result-cache ]; then tar -C build -cf "$out/result-cache.tar" result-cache; fi
    printf 'part=%s\nk=%s\nn=%s\nrc=%s\ntree=%s\ncmd=%s\nsecs=%s\ncache=%s\n' \
        "$part" "$k" "$n" "$rc" "$(tree)" "$cmds" "$secs" "$cache" > "$out/part.txt"
    exit "$rc"
    ;;
cdiff)
    prep=$(cd "$2" && pwd)
    mkdir -p "$3"
    out=$(cd "$3" && pwd)
    status=$(sed -n 's/^status=//p' "$prep/gate-meta.txt" 2>/dev/null || true)
    sed 's/^gate /cdiff /' "$prep/rev.txt" > "$out/rev.txt" 2>/dev/null || true
    echo "run ${GITHUB_RUN_ID:-local} attempt ${GITHUB_RUN_ATTEMPT:-1}, $(date -u '+%Y-%m-%d %H:%M UTC')" > "$out/computed.txt"
    if [ "$status" != PREPARED ] || [ ! -f "$prep/tree.tar.zst" ]; then
        # a conflict, or a prep that failed: the gate reports it; no C diff
        echo "base C: none (no merged tree; prep status: ${status:-missing})" | tee "$out/cbase.txt"
        exit 0
    fi
    root=${PGATE_ROOT:-$RUNNER_TEMP}
    zstd -q -dc "$prep/tree.tar.zst" | tar -C "$root" -xf -
    h=$root/pgate b=$root/base
    master=$(sed -n 's/^master=//p' "$prep/gate-meta.txt")
    printf 'base=%s\nmerged=%s\n' "$master" "$(sed -n 's/^merged=//p' "$prep/gate-meta.txt")" > "$out/base.txt"
    t0=$(date +%s)
    git -C "$h" worktree add -q --detach "$b" "$master"
    echo "[pgate] base $master checked out in $(( $(date +%s) - t0 ))s" > "$out/base-build.log"
    # the vendored parsers: the merged tree's when the master's Makefile
    # asks for the same ones (the build job's cache key), else fetched
    vkey() { { grep -E '^(PRISM|RBS)_VERSION' "$1/Makefile"; sed -n '/^deps:/,/^DIST_RELEASE/p' "$1/Makefile"; } | sha256sum | cut -c1-16; }
    if [ -d "$h/vendor" ] && [ "$(vkey "$h")" = "$(vkey "$b")" ]; then cp -R "$h/vendor" "$b/"; fi
    if ! (cd "$b" && { make deps || { sleep 30; make deps; }; } && make -j"$jobs" all) >> "$out/base-build.log" 2>&1; then
        echo "[pgate] the base $master did not build (base-build.log)" | tee -a "$out/cbase.txt"
        exit 1
    fi
    echo "[pgate] base $master built in $(( $(date +%s) - t0 ))s" >> "$out/base-build.log"
    t0=$(date +%s)
    BASE=$master "$here/cdiff-leg.sh" "$h" "$b" "$out" "$4"
    echo "[pgate] C diff in $(( $(date +%s) - t0 ))s" >> "$out/base-build.log"
    ;;
*)
    echo "usage: pgate.sh prep CHECKOUT OUT | pch CHECKOUT OUT HIT | part PREP OUT PART K N | cdiff PREP OUT CACHE" >&2
    exit 2
    ;;
esac

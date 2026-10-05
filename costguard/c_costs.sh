#!/usr/bin/env bash
# c_costs.sh -- count the constructs in generated C that cost at run time,
# and compare two compilers' C for the same programs (#7501).
#
#   tools/c_costs.sh FILE.c                     counts for one C file
#   tools/c_costs.sh REF.c NEW.c [LABEL]        one program, ref against new
#   tools/c_costs.sh --list FILE                the same for each line
#                                               `LABEL REF.c NEW.c` of FILE
#   tools/c_costs.sh REF_SPINEL NEW_SPINEL PROGS...
#                                               compile each program with both
#                                               (-S --no-line-map) and compare
#
# A correct program can get slower without any output changing: a String
# slot that became a shared handle copies its bytes at every read-only call
# (#7482), a receiver that became boxed dispatches out of line. The tests
# cannot see that; the C can. Counted per program:
#   snap   handle snapshot copies: sp_str_concat(sp_String_cstr(h), "")
#   dup    other O(len) copies: sp_*_dup / sp_*_dup_external / sp_*_copy
#          (sp_str_dup, sp_String_dup, sp_IntArray_dup, sp_strbuf_copy, ...)
#   box    boxings: sp_box_* calls but sp_box_nil
#   pd     out-of-line dispatch calls: sp_pd_*
#   root   GC root registrations: SP_GC_ROOT, SP_GC_ROOT_STR, SP_GC_ROOT_RBVAL
# each twice: everywhere, and inside a loop. A loop is a for/while/do body
# or header in the C, which is where `while`, `until`, `loop`, `n.times`,
# `each`, `map` and the other inlined block iterations land; a function
# with a call site inside a loop, or inside such a function, counts as in
# a loop too (the call graph is followed to a fixpoint, as spinel-doctor's
# advice leg does). A block the runtime library iterates itself (a lifted
# block passed to a library function) is not seen as a loop body.
#
# The strongest signal is a new snapshot or dup inside a loop: an O(len)
# operation per iteration. Each one is listed on its own line, with the
# function it is in.
#
# Exit status: 0, or 2 on a usage or infrastructure error. The counts are
# a report, not a verdict.
set -u
JOBS=${C_COSTS_JOBS:-2}
CATS="snap dup box pd root"

# The counter. Per C file it prints `T <cat> <everywhere> <in-loop>` and,
# for each function with an in-loop count, `F <cat> <function> <in-loop>`.
COUNT_AWK='
function flush_word(   cat, rest, k) {
  if (word == "") return
  if (nextc == "(") {
    cat = ""
    if (word == "sp_str_concat") {
      rest = substr(s, i)
      sub(/^[ \t]*\([ \t]*/, "", rest)
      if (rest ~ /^sp_String_cstr[ \t]*\(/) cat = "snap"
    }
    else if (word ~ /^sp_[A-Za-z0-9_]*_(dup|dup_external|copy)$/) cat = "dup"
    else if (word ~ /^sp_box_/ && word != "sp_box_nil") cat = "box"
    else if (word ~ /^sp_pd_/) cat = "pd"
    else if (word ~ /^SP_GC_ROOT(_STR|_RBVAL)?$/) cat = "root"
    if (depth > 0) {
      if (cat != "") {
        all[fn, cat]++
        if (nloop > 0 || pend || single) lex[fn, cat]++
      }
      if (word != fn) { ne++; efrom[ne] = fn; eto[ne] = word; eloop[ne] = (nloop > 0 || pend || single) }
    }
    else if (paren == 0) cand = word
    if ((word == "for" || word == "while") && !pend) {
      rest = substr(s, i)
      if (!(word == "while" && rest ~ /^[ \t]*\([ \t]*0[ \t]*\)/)) { pend = 1; pparen = paren }
    }
  }
  if (word == "do" && nextc == "{") dobody = 1
  word = ""
}
{
  if ($0 ~ /^[ \t]*#/) next
  s = $0
  gsub(/\047([^\047\\]|\\.)\047/, "0", s)
  gsub(/"([^"\\]|\\.)*"/, "\"\"", s)
  n = length(s)
  for (i = 1; i <= n; i++) {
    ch = substr(s, i, 1)
    # a loop header closed without a brace: its body is one statement
    if (await && ch !~ /[ \t{]/) { await = 0; single = 1 }
    if (ch ~ /[A-Za-z0-9_]/) { word = word ch; continue }
    if (word != "") {
      # the next non-blank character decides whether the word is called
      j = i; while (j <= n && substr(s, j, 1) ~ /[ \t]/) j++
      nextc = j <= n ? substr(s, j, 1) : ""
      flush_word()
    }
    if (ch == "(") paren++
    else if (ch == ")") {
      paren--
      if (pend && paren == pparen) { pend = 0; await = 1; continue }
    }
    else if (ch == "{") {
      if (depth == 0) { fn = cand; defined[fn] = 1 }
      depth++
      if (await || dobody) { nloop++; loopd[nloop] = depth; await = 0; dobody = 0 }
    }
    else if (ch == "}") {
      if (nloop > 0 && loopd[nloop] == depth) nloop--
      depth--
      if (depth <= 0) { depth = 0; fn = ""; cand = ""; nloop = 0 }
    }
    else if (ch == ";") {
      if (single && paren == 0) single = 0
      if (depth == 0 && paren == 0) cand = ""
    }
  }
  if (word != "") { nextc = ""; flush_word() }
}
END {
  # a function called from inside a loop, or from such a function, runs
  # per iteration: follow the call graph to a fixpoint
  changed = 1
  while (changed) {
    changed = 0
    for (k = 1; k <= ne; k++)
      if ((eto[k] in defined) && !hot[eto[k]] && (eloop[k] || hot[efrom[k]])) { hot[eto[k]] = 1; changed = 1 }
  }
  nc = split(cats, cl, " ")
  for (key in all) {
    split(key, kp, SUBSEP)
    tot[kp[2]] += all[key]
    v = hot[kp[1]] ? all[key] : lex[key]
    if (v > 0) { inl[kp[2]] += v; print "F", kp[2], (kp[1] == "" ? "-" : kp[1]), v }
  }
  for (c = 1; c <= nc; c++) print "T", cl[c], tot[cl[c]] + 0, inl[cl[c]] + 0
}'

count() { awk -v cats="$CATS" "$COUNT_AWK" "$1"; }

# One program: prints `P <label> <cat> <ref> <ref-in-loop> <new> <new-in-loop>`
# per category and `L <label> <cat> <function> <ref-in-loop> <new-in-loop>`
# for each function whose in-loop O(len) count rose.
compare() {
  local label=$1 a b
  a=$(count "$2") || return 2
  b=$(count "$3") || return 2
  awk -v label="$label" -v cats="$CATS" '
    FNR == 1 { side++ }
    $1 == "T" { t[side, $2] = $3; l[side, $2] = $4 }
    $1 == "F" && ($2 == "snap" || $2 == "dup") { f[side, $2, $3] = $4; fk[$2 SUBSEP $3] = 1 }
    END {
      nc = split(cats, cl, " ")
      for (c = 1; c <= nc; c++)
        print "P", label, cl[c], t[1, cl[c]] + 0, l[1, cl[c]] + 0, t[2, cl[c]] + 0, l[2, cl[c]] + 0
      for (k in fk) {
        split(k, kp, SUBSEP)
        if (f[2, kp[1], kp[2]] + 0 > f[1, kp[1], kp[2]] + 0)
          print "L", label, kp[1], kp[2], f[1, kp[1], kp[2]] + 0, f[2, kp[1], kp[2]] + 0
      }
    }' <(printf '%s\n' "$a") <(printf '%s\n' "$b") | LC_ALL=C sort
}

# The report over the P and L records of any number of programs.
summarize() {
  awk -v cats="$CATS" '
    BEGIN {
      name["snap"] = "handle snapshot copies"; name["dup"] = "dup/copy helpers"
      name["box"] = "boxings"; name["pd"] = "out-of-line dispatches"; name["root"] = "GC root registrations"
    }
    function sgn(v) { return v > 0 ? "+" v : v }
    $1 == "P" {
      if (!($2 in seen)) { seen[$2] = 1; order[++np] = $2 }
      ra[$3] += $4; rl[$3] += $5; na[$3] += $6; nl[$3] += $7
      if ($4 != $6 || $5 != $7) {
        if (!($2 in ch)) { ch[$2] = 1; nch++ }
        d[$2] = d[$2] sprintf(" %s %s (%s in loops)", $3, sgn($6 - $4), sgn($7 - $5))
      }
    }
    $1 == "S" { skipped[++ns] = $2 ": " substr($0, index($0, $3)) }
    $1 == "L" { strong[++nst] = sprintf("%s: %s %d -> %d in loops in %s", $2, ($3 == "snap" ? "snapshot copies" : "dup/copy helpers"), $5, $6, $4) }
    END {
      nc = split(cats, cl, " ")
      printf "c_costs: %d programs, %d with changed counts%s\n", np, nch, (ns ? sprintf(", %d skipped", ns) : "")
      printf "  %-24s %16s %16s %18s\n", "everywhere (in loops)", "ref", "new", "delta"
      for (c = 1; c <= nc; c++) {
        k = cl[c]
        printf "  %-24s %16s %16s %18s\n", name[k], ra[k] " (" rl[k] + 0 ")", na[k] " (" nl[k] + 0 ")",
               sgn(na[k] - ra[k]) " (" sgn(nl[k] - rl[k]) ")"
      }
      if (nst) {
        printf "a new O(len) operation (snapshot copy, dup, String/Array copy helper) inside a loop: %d\n", nst
        for (k = 1; k <= nst; k++) print "  " strong[k]
      }
      else print "a new O(len) operation (snapshot copy, dup, String/Array copy helper) inside a loop: none"
      if (nch) {
        print "changed programs:"
        for (k = 1; k <= np; k++) if (order[k] in ch) print "  " order[k] ":" d[order[k]]
      }
      for (k = 1; k <= ns; k++) print "  skipped " skipped[k]
    }'
}

usage() { sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

[ $# -ge 1 ] || usage
if [ "$1" = --list ]; then
  [ $# -eq 2 ] || usage
  while read -r label a b; do
    [ -n "$label" ] || continue
    if [ -f "$a" ] && [ -f "$b" ]; then compare "$label" "$a" "$b"
    else echo "S $label no C on one side"; fi
  done < "$2" | summarize
elif [ $# -eq 1 ]; then
  [ -f "$1" ] || usage
  count "$1" | awk '$1 == "T" { printf "%s %d (%d in loops)\n", $2, $3, $4 }'
elif [ -f "$1" ] && [ -f "$2" ] && [ "${1%.c}" != "$1" ]; then
  [ $# -le 3 ] || usage
  compare "${3:-$2}" "$1" "$2" | summarize
else
  REF=$1 NEW=$2; shift 2
  [ -x "$REF" ] && [ -x "$NEW" ] || { echo "c_costs: $REF and $NEW must be spinel binaries" >&2; exit 2; }
  [ $# -ge 1 ] || usage
  T=$(mktemp -d "${TMPDIR:-/tmp}/spinel-c-costs.XXXXXX") || exit 2
  trap 'rm -rf "$T"' EXIT
  export -f count compare
  export CATS COUNT_AWK
  printf '%s\n' "$@" | xargs -P "$JOBS" -I{} bash -c '
    p=$1; k=$(printf %s "$p" | tr / _)
    "$2" -S --no-line-map "$p" > "$4/$k.ref.c" 2>/dev/null; ra=$?
    "$3" -S --no-line-map "$p" > "$4/$k.new.c" 2>/dev/null; rb=$?
    if [ $ra -ne 0 ] || [ $rb -ne 0 ]; then echo "S $p does not compile (ref $ra, new $rb)" > "$4/$k.rec"
    else compare "$p" "$4/$k.ref.c" "$4/$k.new.c" > "$4/$k.rec"; fi
    rm -f "$4/$k.ref.c" "$4/$k.new.c"' _ {} "$REF" "$NEW" "$T"
  cat "$T"/*.rec 2>/dev/null | summarize
fi

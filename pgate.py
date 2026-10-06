#!/usr/bin/env python3
# The parallel gate (the pgate leg): `make gate` as parallel jobs on one
# merged tree, and their results added up into the gate leg's files.
#
# usage: pgate.py check CHECKOUT
#          fail unless the tree's gate splits the way pgate splits it
#        pgate.py group CHECKOUT K N SUITE...
#          the K-th of N groups of the rubyspec suites, balanced by
#          expected-PASS examples
#        pgate.py finish --prep DIR --parts DIR --out DIR --name NAME
#                        --expect "legs-0 corpus-1 ..." [--checkout DIR]
#          gate-meta.txt, gate-summary.txt and gate.log in the gate leg's
#          format, from the prep job's directory and the parts' artifacts
#
# What `make gate` runs, and where pgate runs it:
#   gate.rb start                prep, before the build, as the recipe does
#   make all $(SPINEL_TIMEOUT)   prep; every part unpacks its tree
#   gate-legs                    legs: `make gate-legs TESTS= PKG_TESTS=
#                                RUBYSPEC_SUITES=`, every leg with the
#                                corpus and the ruby/spec suites taken out:
#                                test's C-side legs, bench, optcarrot,
#                                props, and test-corpus-summary over nothing
#     the corpus                 corpus k/S: `make test-corpus TEST_SHARD=k/S
#                                OPT=-O1` (gate-test's -O1); the Makefile's
#                                slices are disjoint and cover the corpus
#     the ruby/spec suites       rubyspec k/R: `make gate-rubyspec
#                                RUBYSPEC_SUITES=<group k>`; the groups
#                                partition the tree's RUBYSPEC_SUITES
#   gate.rb stamp                finish, on the prep's tree with every
#                                slice's results, when every part passed
#   echo "gate: ALL GREEN"       finish, when every part passed
# `check` holds the tree to that shape (the rules below, and the three
# variables read nowhere else), so a Makefile change that would let a part
# drop a target stops pgate instead. `finish` checks the parts covered the
# corpus and the suites, each once.
import os, re, shutil, subprocess, sys, tarfile

# The rules the split depends on, as master has them (5cd50e094): each
# target's rule lines, prerequisites and recipe, in order.
EXPECTED = {
    "gate": [("", [
        '@r=$$(sh tools/gate-ruby) && "$$r" tools/gate.rb start || true',
        "+@$(MAKE) --no-print-directory all $(SPINEL_TIMEOUT)",
        "+@$(MAKE) --no-print-directory gate-legs",
        '@r=$$(sh tools/gate-ruby) && CC="$(CC)" "$$r" tools/gate.rb stamp || true',
        '@echo "gate: ALL GREEN"'])],
    "gate-legs": [("gate-test gate-bench gate-optcarrot gate-rubyspec gate-props", [])],
    "gate-test": [("", ["+@$(MAKE) --no-print-directory test OPT=-O1"])],
    "gate-rubyspec": [("", ["+@$(MAKE) --no-print-directory rubyspec-gate"])],
    "test-corpus": [("$(SPINEL_TIMEOUT)", [
        "+@$(MAKE) --no-print-directory clean-test-results",
        "+@$(MAKE) $(TEST_JOBS) --no-print-directory test-corpus-summary"])],
}
# The only targets that may reach the corpus targets (by prerequisite or a
# recursive make): with TESTS= the legs part runs them over nothing, so a
# new way in would drop its programs.
CORPUS = {"test", "test-run", "test-corpus", "test-corpus-summary"}
CORPUS_CALLERS = {"test", "test-run", "test-corpus", "gate-test", "check"}
# Where the variables the parts override may be read: their definitions, the
# shard check, the corpus targets and the rubyspec loops.
VAR_REF = re.compile(r"\$[({](TESTS|PKG_TESTS|TEST_TARGETS|PKG_TEST_TARGETS|RUBYSPEC_SUITES)[)}]")
VAR_OK = [re.compile(p) for p in (
    r"^(TESTS|PKG_TESTS|SHARD_ALL|TEST_TARGETS|PKG_TEST_TARGETS|EXPECTED_FILES|RUBYSPEC_SUITES)\s*[:?+]?=",
    r"^ifeq \(\$\(TESTS\),\)$",
    r"^test-corpus-summary:",
    r"^\t@(ok=1; )?for d in \$\(RUBYSPEC_SUITES\); do \\$")]


def rules(text, names=None):
    """{target: [(prerequisites, recipe lines)]}, every target or the named."""
    out = {n: [] for n in names} if names else {}
    cur = None
    for line in text.splitlines():
        if line.startswith("\t") and cur is not None:
            cur[1].append(line[1:].rstrip())
            continue
        cur = None
        m = re.match(r"^([^\s:#=][^:=]*?)\s*:(?![:=])\s*(.*?)\s*$", line)
        if m:
            for t in m.group(1).split():
                if names is None or t in out:
                    cur = (m.group(2), [])
                    out.setdefault(t, []).append(cur)
    return out


def check(checkout):
    text = open(os.path.join(checkout, "Makefile"), errors="replace").read()
    common = os.path.join(checkout, "common.mk")
    mk = text + "\n" + (open(common, errors="replace").read() if os.path.exists(common) else "")
    got = rules(text, list(EXPECTED) + ["test-run", "test"])
    bad = [f"the {t} rule" for t, want in EXPECTED.items() if got[t] != want]
    if not any("test-corpus-summary" in pre.split() for pre, _ in got["test-run"]):
        bad.append("test-run (it no longer runs test-corpus-summary)")
    if not any(re.search(r"\$\(MAKE\).* test-run$", r) for _, rec in got["test"] for r in rec):
        bad.append("test (it no longer runs test-run)")
    callers = set()
    for t, rs in rules(text).items():
        for pre, rec in rs:
            if CORPUS & set(pre.split()) or any("$(MAKE)" in r and CORPUS & set(r.split()) for r in rec):
                callers.add(t)
    if callers - CORPUS_CALLERS:
        bad.append(f"the corpus targets, now also reached from {' '.join(sorted(callers - CORPUS_CALLERS))}")
    for line in mk.splitlines():
        if not line.lstrip().startswith("#") and VAR_REF.search(line) and not any(p.search(line) for p in VAR_OK):
            bad.append(f"a new reader of an overridden variable: {line.strip()[:120]}")
    for b in bad:
        print(f"[pgate] the tree changed {b}; run the gate leg, or update pgate.py")
    if bad:
        return 1
    print("[pgate] the tree's gate splits as pgate splits it")
    return 0


def groups(checkout, n, suites):
    """The suites in n groups, longest-processing-time first by each suite's
    expected-PASS count; deterministic, so every shard computes the same."""
    def weight(s):
        p = os.path.join(checkout, "tools/rubyspec/expectations", s.replace("/", "-") + ".tsv")
        try:
            with open(p, errors="replace") as f:
                return max(1, sum(1 for l in f if l.rstrip("\n").split("\t")[1:2] == ["PASS"]))
        except OSError:
            return 1
    bins = [[0, i, []] for i in range(n)]
    for s in sorted(dict.fromkeys(suites), key=lambda s: (-weight(s), s)):
        b = min(bins, key=lambda b: (b[0], b[1]))
        b[0] += weight(s)
        b[2].append(s)
    return [b[2] for b in bins]


def read(path, default=""):
    try:
        with open(path, errors="replace") as f:
            return f.read()
    except OSError:
        return default


def kv(text):
    return dict(l.split("=", 1) for l in text.splitlines() if "=" in l)


SUMMARY = re.compile(r"Tests:|scale-test|gate:")
TESTS = re.compile(r"Tests:\s+(\d+) pass,\s+(\d+) fail,\s+(\d+) error")


def finish(a):
    prep, out, name = a["--prep"], a["--out"], a["--name"]
    os.makedirs(out, exist_ok=True)
    meta = kv(read(os.path.join(prep, "gate-meta.txt")))
    rev = read(os.path.join(prep, "rev.txt"))
    log = [read(os.path.join(prep, "gate.log")).rstrip("\n")]
    expect = a["--expect"].split()
    status, rc, summary = "FAIL", 1, []

    def write():
        m = {k: meta.get(k, "unknown") for k in ("master", "merged", "merge_base")}
        with open(os.path.join(out, "gate-meta.txt"), "w") as f:
            f.write("".join(f"{k}={v}\n" for k, v in m.items()) +
                    f"status={status}\nexit_status={rc}\ntarget=gate\n"
                    f"mode=pgate\nparts={' '.join(expect)}\n")
        with open(os.path.join(out, "gate-summary.txt"), "w") as f:
            f.write("".join(l + "\n" for l in summary))
        with open(os.path.join(out, "gate.log"), "w") as f:
            f.write("\n".join(l for l in log if l) + "\n")
        with open(os.path.join(out, "rev.txt"), "w") as f:
            f.write(rev or f"gate {name} 0 ?\n")

    pstatus = meta.get("status", "")
    if pstatus == "CONFLICT":
        status, rc = "CONFLICT", int(meta.get("exit_status", 1) or 1)
        summary = read(os.path.join(prep, "gate-summary.txt")).splitlines()
        write()
        return 0
    if pstatus != "PREPARED":
        log.append(f"[pgate] the prep job did not finish (status {pstatus or 'missing'}); no part ran")
        rc = int(meta.get("exit_status", 1) or 1) or 1
        write()
        return rc

    fails, notes, times = [], [], []
    parts = {}
    for p in expect:
        d = os.path.join(a["--parts"], f"pg-{p}--{name}")
        pm = kv(read(os.path.join(d, "part.txt")))
        plog = read(os.path.join(d, "part.log")).rstrip("\n")
        if "rc" not in pm:
            fails.append((p, 1))
            log.append(f"=== [pgate] part {p}: no result (the job did not finish or its artifact is missing)")
            continue
        parts[p] = (d, pm, plog)
        log.append(f"=== [pgate] part {p}: {pm.get('cmd', '?')} (exit {pm['rc']})\n{plog}")
        if pm["rc"] != "0":
            fails.append((p, int(pm["rc"]) if pm["rc"].isdigit() else 1))
        if pm.get("secs"):
            times.append(f"{p} {pm['secs']}s" + (f" ({pm['cache']})" if pm.get("cache") else ""))
    if times:
        log.append("[pgate] part times: " + ", ".join(times))

    # the gate's own lines, in the gate's order: the legs' lines, the corpus
    # total, then the stamp
    lines = []
    for p in sorted(parts, key=lambda p: (p.startswith("corpus-"), expect.index(p))):
        lines += [l for l in parts[p][2].splitlines() if SUMMARY.search(l) and not TESTS.search(l)]
    tp = tf = te = 0
    seen, dup, nok = set(), [], 0
    for p in parts:
        m = TESTS.findall(parts[p][2])
        if m:
            x, y, z = map(int, m[-1])
            tp, tf, te = tp + x, tf + y, te + z
        elif p.startswith(("corpus-", "legs-")):
            notes.append(f"[pgate] part {p} printed no Tests line")
        if p.startswith("corpus-"):
            try:
                with tarfile.open(os.path.join(parts[p][0], "test-results.tar")) as t:
                    for n in t.getnames():
                        if re.fullmatch(r"(\./)?test-results/[^/.][^/]*\.ok", n):
                            nok += 1
                            (dup.append(n) if n in seen else seen.add(n))
            except (OSError, tarfile.TarError):
                notes.append(f"[pgate] part {p} has no test-results.tar")
    lines.append(f"Tests: {tp} pass, {tf} fail, {te} error")
    # coverage: every corpus program once, every rubyspec suite once
    want = int(meta.get("ntests", "-1") or -1)
    # coverage fails on a target that has no result, or one run twice; a result that is no target (an
    # extra .ok) is only reported
    tfile = os.path.join(a.get("--prep", ""), "targets.txt")
    if os.path.exists(tfile):
        tg = {os.path.basename(l.strip()) for l in open(tfile) if l.strip()}
        got = {os.path.basename(n_) for n_ in seen}
        missing = sorted(t_ for t_ in tg if t_ not in got)
        extra = sorted(g_ for g_ in got if g_ not in tg)
        if extra: notes.append(f"[pgate] results that are no target (not counted): {' '.join(extra[:10])}")
        if not fails and (missing or dup):
            notes.append(f"[pgate] the corpus slices missed {len(missing)} programs ({' '.join(missing[:10])}) and ran {len(dup)} twice")
    elif not fails and (nok != want or dup or tp + tf + te != want):
        notes.append(f"[pgate] the corpus slices ran {nok} programs ({len(dup)} twice, {tp + tf + te} counted); the tree has {want}")
    suites = meta.get("rubyspec_suites", "").split()
    ran = [s for p in parts for s in re.findall(r"^rubyspec-gate\[([^\]]+)\]:", parts[p][2], re.M)]
    if not fails and sorted(ran) != sorted(suites):
        notes.append(f"[pgate] the rubyspec groups ran {' '.join(sorted(ran)) or 'no suite'}; the tree's RUBYSPEC_SUITES is {' '.join(sorted(suites))}")
    log += notes
    if fails:
        log.append("[pgate] FAIL in " + ", ".join(p for p, _ in fails))
    if fails or notes:
        rc = fails[0][1] if fails else 1
        summary = lines
        write()
        return rc

    # the stamp, on the prep's tree, when every part left the tree as the
    # gate started it (gate.rb's own check, made in each part)
    start = meta.get("start", "")
    moved = [p for p in parts if parts[p][1].get("tree", "") != start]
    co = a.get("--checkout")
    if moved or not start:
        log.append(f"[pgate] parts {' '.join(moved)} left the tree changed" if start else
                   "[pgate] gate.rb start recorded no tree")
        log.append("gate: the tree is not the one the gate started on; no stamp")
        lines.append(log[-1])
    elif co and os.path.isdir(co):
        res = os.path.join(co, "build", "test-results")
        subprocess.run(["rm", "-rf", res], check=True)
        os.makedirs(res)
        for p in expect:
            if p.startswith("corpus-"):
                with tarfile.open(os.path.join(parts[p][0], "test-results.tar")) as t:
                    t.extractall(os.path.join(co, "build"), filter="data")
        env = dict(os.environ, GATE_MASTER=meta.get("master", ""))
        if meta.get("cc"):
            env["CC"] = meta["cc"]
        r = subprocess.run(["sh", "-c", 'r=$(sh tools/gate-ruby) && "$r" tools/gate.rb stamp || true'],
                           cwd=co, env=env, capture_output=True, text=True)
        stamp = (r.stdout + r.stderr).rstrip("\n")
        log.append(stamp)
        # the stamp itself, for the Gate: trailer of a head gated alone
        # (gate.rb trailer's line; verify checks it against master + head)
        gd = subprocess.run(["git", "rev-parse", "--absolute-git-dir"], cwd=co, capture_output=True, text=True).stdout.strip()
        sp = os.path.join(gd, "gate-stamp") if gd else ""
        if os.path.isfile(sp):
            shutil.copy(sp, os.path.join(a["--out"], "gate-stamp.txt"))
        lines += [l for l in stamp.splitlines() if SUMMARY.search(l)]
    lines.append("gate: ALL GREEN")
    log.append("gate: ALL GREEN")
    status, rc, summary = "PASS", 0, lines
    write()
    return 0


def main(argv):
    cmd = argv[1] if len(argv) > 1 else ""
    if cmd == "check":
        return check(argv[2])
    if cmd == "group":
        k, n = int(argv[3]), int(argv[4])
        print(" ".join(groups(argv[2], n, argv[5:])[k - 1]))
        return 0
    if cmd == "finish":
        return finish(dict(zip(argv[2::2], argv[3::2])))
    print("usage: pgate.py check CHECKOUT | group CHECKOUT K N SUITE... | finish --prep DIR --parts DIR "
          "--out DIR --name NAME --expect PARTS [--checkout DIR]", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))

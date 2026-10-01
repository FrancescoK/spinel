#!/usr/bin/env python3
# usage: report.py RESDIR -- one Markdown report out of the run's artifacts
import os, re, sys

res = sys.argv[1]
jobs = {}
for d in sorted(os.listdir(res)):
    m = re.match(r"r-(suite|cb|vf|nn|cdiff|extra|scale|rubyspec)-(.+)-(\d+)$", d)
    if m:
        jobs[(m.group(1), m.group(2), int(m.group(3)))] = os.path.join(res, d)

def read(path, default=""):
    try:
        with open(path, errors="replace") as f:
            return f.read()
    except OSError:
        return default

def cases(d):
    out = set()
    for root, _, files in os.walk(os.path.join(d, "probe")):
        for f in files:
            if re.match(r"case_\d+\.rb$", f):
                out.add(os.path.relpath(os.path.join(root, f), os.path.join(d, "probe")))
    return out

def origin(d):
    # a base result: from the cache (cache.txt, the key) or computed in this run
    run = read(os.path.join(d, "computed.txt")).strip()
    if os.path.exists(os.path.join(d, "cache.txt")):
        return f"from the cache, computed by {run or 'an earlier run'}"
    return "computed in this run" if run else ""

def rs_dirs(name):
    # the rubyspec gate's shards for a name, in order (one shard 0 before sharding)
    return [d for (l, nm, k), d in sorted(jobs.items()) if l == "rubyspec" and nm == name]

def rs_lines(dirs, tag):
    # each shard's last lines of note, merged; the ruby/spec clone line once
    out = []
    for d in dirs:
        for l in [l.strip() for l in read(os.path.join(d, f"rubyspec-{tag}.log")).splitlines()
                  if re.search(r"rubyspec|REJECT|FAIL|regress", l)][-8:]:
            if not (l.startswith("Cloning into") and l in out):
                out.append(l)
    return out

def summary(d):
    s = read(os.path.join(d, "probe", "summary.txt"))
    m = re.search(r"\d+ cases: [^\n]*", s)
    return m.group(0) if m else "no summary (see probe.log)"

names = sorted({n for (_, n, _) in jobs if n != "base"})
print("# verify\n")
for probe in ("cb", "vf", "nn"):
    if (probe, "base", 0) in jobs:
        d = jobs[(probe, "base", 0)]
        o = origin(d)
        print(f"- base {probe}: {summary(d)} ({read(os.path.join(d, 'rev.txt')).split(' ', 3)[-1].strip()})" +
              (f"; {o}" if o else ""))
rsb = [(k, d) for (l, nm, k), d in sorted(jobs.items()) if l == "rubyspec" and nm == "base"]
if len(rsb) == 1:
    print(f"- base rubyspec-gate: {origin(rsb[0][1]) or 'no result'}")
elif rsb:
    print(f"- base rubyspec-gate: {'; '.join(f'shard {k} ' + (origin(d) or 'no result') for k, d in rsb)}")
print()
for n in names:
    rev = next((read(os.path.join(d, "rev.txt")).split(" ", 3)[-1].strip()
                for (l, nm, _), d in jobs.items() if nm == n), "?")
    print(f"## {n}: {rev}\n")
    shards = sorted((k, d) for (l, nm, k), d in jobs.items() if l == "suite" and nm == n)
    if shards:
        tp = tf = te = 0
        fails, notes = [], []
        for k, d in shards:
            log = read(os.path.join(d, "test.log"))
            m = re.findall(r"Tests:\s+(\d+) pass,\s+(\d+) fail,\s+(\d+) error", log)
            if not m:
                notes.append(f"slice {k}: no Tests line")
                fails += [l for l in log.splitlines() if "rror" in l][-5:]
                continue
            p, f, e = map(int, m[-1]); tp += p; tf += f; te += e
            fails += [l for l in log.splitlines() if re.search(r"FAIL|: fail", l)]
        corpus = read(os.path.join(shards[0][1], "corpus.txt")).strip()
        print(f"- suite ({len(shards)} slices): {tp} pass, {tf} fail, {te} error; corpus {corpus} programs" +
              (f"; {'; '.join(notes)}" if notes else ""))
        infer = read(os.path.join(shards[0][1], "infer.log")).strip().splitlines()
        if infer:
            print(f"- infer-test: {infer[-1]}")
        rates = [re.search(r"Cache hits rate\s+([\d.]+ %)", read(os.path.join(d, "sccache.txt"))) for _, d in shards]
        if any(rates):
            print(f"- sccache hits per slice: {', '.join(m.group(1) if m else '?' for m in rates)}")
        for l in fails[:30]:
            print(f"  - `{l.strip()}`")
    for probe in ("cb", "vf", "nn"):
        if (probe, n, 0) in jobs:
            d = jobs[(probe, n, 0)]
            line = f"- {probe}: {summary(d)}"
            if (probe, "base", 0) in jobs:
                b, h = cases(jobs[(probe, 'base', 0)]), cases(d)
                if b == h:
                    line += "; same case files as base"
                else:
                    line += f"; vs base: {len(h - b)} new, {len(b - h)} gone"
                    for c in sorted(h - b)[:20]:
                        line += f"\n  - new: {c}"
                    for c in sorted(b - h)[:20]:
                        line += f"\n  - gone: {c}"
            print(line)
    if ("cdiff", n, 0) in jobs:
        d = jobs[("cdiff", n, 0)]
        ch = read(os.path.join(d, "changed.txt")).split()
        total = len(read(os.path.join(d, "programs.txt")).split())
        print(f"- C diff vs base: {len(ch)} of {total} programs change")
        for c in ch[:60]:
            print(f"  - {c}")
        cbase = " ".join(l.strip() for l in read(os.path.join(d, "cbase.txt")).splitlines() if l.strip())
        if cbase:
            print(f"- C diff, the base's side: {cbase}")
    if ("scale", n, 0) in jobs:
        d = jobs[("scale", n, 0)]
        spin = read(os.path.join(d, "spin.txt")).strip()
        if spin:
            print(f"- {spin}" + ("" if spin.endswith("pass") else "\n" + "\n".join(
                f"  - `{l.strip()}`" for l in read(os.path.join(d, "spin.log")).splitlines()[-8:])))
        for tag, f in (("head", "scale.log"), ("base", "scale-base.log")):
            lines = [l.strip() for l in read(os.path.join(d, f)).splitlines() if l.startswith("scale-test")]
            print(f"- scale-test ({tag}):")
            for l in lines:
                print(f"  - {l}")
    if rs_dirs(n):
        for tag in ("head", "base"):
            # the base's gate is jobs of its own; before, the head's job ran both
            rs = rs_lines(rs_dirs("base") or rs_dirs(n) if tag == "base" else rs_dirs(n), tag)
            print(f"- rubyspec-gate ({tag}):")
            for l in rs:
                print(f"  - `{l}`")
    if ("extra", n, 0) in jobs:
        d = jobs[("extra", n, 0)]
        lines = read(os.path.join(d, "extra.txt")).strip().splitlines()
        print(f"- new tests (plain, promote, GC stress): {'none' if not lines else ''}")
        for l in lines:
            print(f"  - {l}")
    missing = [f"{l} {k}" if k else l for (l, nm, k) in
               [(l, nm, k) for (l, nm, k) in jobs if nm == n] if not os.listdir(jobs[(l, nm, k)])]
    if missing:
        print(f"- empty artifacts: {', '.join(missing)}")
    print()

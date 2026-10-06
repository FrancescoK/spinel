#!/usr/bin/env python3
# usage: report.py RESDIR -- one Markdown report out of the run's artifacts
import os, re, sys

res = sys.argv[1]
jobs = {}
for d in sorted(os.listdir(res)):
    m = re.match(r"r-(suite|cb|vf|nn|brow|dc|lit|op|ord|cdiff|cident|extra|scale|rubyspec|gate|pgate)-(.+)-(\d+)$", d)
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

# The sharded probes: brow (the builtin-row probe, in --shard slices of its
# ops) and Matz's corpus probes dc, lit, op and ord (each shard a slice of
# the tool's FILE set). Each shard's summary.txt is read in the tool's own
# terms; the shards of a tree are added up, and the findings compared with
# the base's over the shards both sides completed.
SHARDED = ("brow", "dc", "lit", "op", "ord")
DONE = {"brow": r"^\d+ cases: ", "dc": r"^findings: \d+ in ", "lit": r"^findings: \d+ programs, ",
        "op": r"^findings: \d+ programs, ", "ord": r"^findings: \d+ programs, "}

def shard_dirs(leg, name):
    return [(k, d) for (l, nm, k), d in sorted(jobs.items()) if l == leg and nm == name]

def lines_after(s, head):
    # the indented lines under the first line matching `head`, to a blank line
    out, on = [], False
    for l in s.splitlines():
        if on:
            if not l.strip():
                break
            out.append(l)
        elif re.match(head, l):
            on = True
    return out

def num(pat, s, n=1):
    m = re.search(pat, s, re.M)
    return [int(m.group(i)) for i in range(1, n + 1)] if m else [0] * n

def probe_shard(leg, d):
    """(counts, ids) of one shard: counts a dict of numbers to add up, ids
    the findings (cases, files or calls) by a name that does not hold the
    shard's own numbering. None when the shard has no finished summary."""
    p = os.path.join(d, "probe")
    s = read(os.path.join(p, "summary.txt"))
    if not re.search(DONE[leg], s, re.M):
        return None
    c, ids = {}, set()
    if leg == "brow":
        c["cases"], c["wrong"], c["refused"], c["documented"] = \
            num(r"^(\d+) cases: (\d+) wrong, (\d+) refused, (\d+) documented", s, 4)
        for l in lines_after(s, r"^\d+ cases: "):
            m = re.match(r"^  (.+): (\d+)$", l)
            if m:
                c["label " + m.group(1)] = int(m.group(2))
        ids = cases(d)
    elif leg == "dc":
        c["given"], c["probed"], c["builds"] = num(r"^programs: (\d+) given, (\d+) probed, (\d+) builds", s, 3)
        c["findings"], c["in"], c["wrong"], c["refused"] = \
            num(r"^findings: (\d+) in (\d+) programs: (\d+) wrong, (\d+) refused", s, 4)
        for l in lines_after(s, r"^findings: "):
            m = re.match(r"^  (\S+) +(\d+)  ", l)
            if m:
                c["label " + m.group(1)] = int(m.group(2))
        label = None
        for l in s.splitlines():
            m = re.match(r"^([a-z-]+):$", l)
            if m:
                label = m.group(1)
            m = re.match(r"^    findings/\d+-(\S+)  (.*?)(  \(not cut down\))?$", l)
            if m and label:
                ids.add(f"{label} {m.group(1)}: {m.group(2)}")
    elif leg == "lit":
        c["programs"], c["compared"] = num(r"^programs: (\d+), (\d+) compared", s, 2)
        c["findings"] = num(r"^findings: (\d+) programs, ", s)[0]
        for f in sorted(os.listdir(os.path.join(p, "findings")) if os.path.isdir(os.path.join(p, "findings")) else []):
            m = re.search(r"^family: (.*) \((\w+), \d+ programs?\)$", read(os.path.join(p, "findings", f, "note.txt")), re.M)
            if not m:
                continue
            c["family " + m.group(2) + " " + m.group(1)] = 1
            for l in read(os.path.join(p, "findings", f, "programs.txt")).splitlines():
                ids.add(f"{m.group(2)} {m.group(1)}: {l.split(chr(9))[0]}")
        # a program once per class, however many families it is in
        for klass, _ in {(i.split(" ", 1)[0], i.rsplit(": ", 1)[1]) for i in ids}:
            c["class " + klass] = c.get("class " + klass, 0) + 1
    elif leg == "op":
        c["given"], c["asked"] = num(r"^programs: (\d+) given, (\d+) asked", s, 2)
        c["findings"], c["calls"] = num(r"^findings: (\d+) programs, (\d+) calls", s, 2)
        for l in lines_after(s, r"^findings: "):
            m = re.match(r"^  (\w+) +(\d+) programs +(\d+) calls$", l)
            if m:
                c["programs " + m.group(1)], c["calls " + m.group(1)] = int(m.group(2)), int(m.group(3))
        c["sequence"] = len(lines_after(s, r"^sequence \("))
        fd = os.path.join(p, "findings")
        for f in sorted(os.listdir(fd)) if os.path.isdir(fd) else []:
            t = read(os.path.join(fd, f, "calls.txt")).splitlines()
            for l in t[1:]:
                m = re.match(r"^line (\d+), column (\d+)  (\S+)  (\w+)", l)
                if m and t:
                    ids.add(f"{m.group(4)} {t[0]}:{m.group(1)}:{m.group(2)} {m.group(3)}")
    elif leg == "ord":
        c["given"], c["compared"] = num(r"^programs: (\d+) given, (\d+) compared", s, 2)
        c["findings"], c["roots"] = num(r"^findings: (\d+) programs, (\d+) root slots", s, 2)
        for l in lines_after(s, r"^findings: "):
            m = re.match(r"^  (\w+) +(\d+)(  \(not counted\))?$", l)
            if m:
                c[("uncounted " if m.group(3) else "class ") + m.group(1)] = int(m.group(2))
        fd = os.path.join(p, "findings")
        for f in sorted(os.listdir(fd)) if os.path.isdir(fd) else []:
            t = read(os.path.join(fd, f, "slots.txt")).splitlines()
            for i, l in enumerate(t):
                if i >= 3 and l and not l.startswith(" ") and not t[i - 1].strip():
                    parts = l.split("  ")
                    if len(parts) > 1:
                        ids.add(f"{parts[1]} {t[0]} {parts[0]}")
    return c, ids

def probe_line(leg, c):
    """A tree's added-up counts in the tool's own terms."""
    def part(prefix, fmt="{k} {v}"):
        xs = sorted(((k[len(prefix):], v) for k, v in c.items() if k.startswith(prefix)), key=lambda kv: -kv[1])
        return ", ".join(fmt.format(k=k, v=v) for k, v in xs)
    if leg == "brow":
        line = f"{c['cases']} cases: {c['wrong']} wrong, {c['refused']} refused, {c['documented']} documented"
        return line + (f" ({part('label ')})" if part("label ") else "")
    if leg == "dc":
        line = (f"programs: {c['given']} given, {c['probed']} probed, {c['builds']} builds and runs; "
                f"findings: {c['findings']} in {c['in']} programs: {c['wrong']} wrong, {c['refused']} refused (not counted)")
        return line + (f" ({part('label ')})" if part("label ") else "")
    if leg == "lit":
        fams = sum(1 for k in c if k.startswith("family "))
        line = f"programs: {c['programs']}, {c['compared']} compared; findings: {c['findings']} programs, {fams} families"
        return line + (f" (programs by class: {part('class ')})" if part("class ") else "")
    if leg == "op":
        line = f"programs: {c['given']} given, {c['asked']} asked; findings: {c['findings']} programs, {c['calls']} calls"
        cl = ", ".join(f"{k[9:]} {v} programs {c.get('calls ' + k[9:], 0)} calls"
                       for k, v in c.items() if k.startswith("programs "))
        return line + (f" ({cl})" if cl else "") + f"; sequence (not counted): {c['sequence']}"
    if leg == "ord":
        line = (f"programs: {c['given']} given, {c['compared']} compared in two orders or more; "
                f"findings: {c['findings']} programs, {c['roots']} root slots")
        line += f" ({part('class ')})" if part("class ") else ""
        return line + (f"; not counted: {part('uncounted ')}" if part("uncounted ") else "")

def probe_tree(leg, name):
    """(line, {shard: ids}, notes) of a tree's shards, added up."""
    total, ids, notes = {}, {}, []
    dirs = shard_dirs(leg, name)
    for k, d in dirs:
        r = probe_shard(leg, d)
        if r is None:
            s = read(os.path.join(d, "probe", "summary.txt")).strip().splitlines()
            notes.append(f"shard {k}: " + (s[0][:120] if s else "no summary (see probe.log)"))
            continue
        for key, v in r[0].items():
            total[key] = total.get(key, 0) + v
        ids[k] = r[1]
    line = probe_line(leg, total) if ids else "no summary"
    if len(ids) < len(dirs):
        line += f" ({len(ids)} of {len(dirs)} shards)"
    return line, ids, notes

def nshards(dirs):
    return f"{len(dirs)} shard{'' if len(dirs) == 1 else 's'}"

def probe_origin(dirs):
    # each shard's origin, alike ones together
    by = {}
    for k, d in dirs:
        by.setdefault(origin(d) or "no result", []).append(str(k))
    return "; ".join(f"shard{'s' if len(ks) > 1 else ''} {', '.join(ks)} {o}" for o, ks in by.items())

names = sorted({n for (_, n, _) in jobs if n != "base"})
print("# verify\n")
# what this run checks: a batch gate runs only pgate, a staged PR only its
# legs, so the other mode's jobs show as skipped on the run page
LEG_NAMES = {"pgate": "parallel gate", "gate": "gate", "cdiff": "corpus C diff", "cident": "cident", "suite": "suite",
             "rubyspec": "rubyspec-gate", "scale": "scale-test", "extra": "new tests"}
ran = sorted({l for (l, _, _) in jobs}, key=lambda l: list(LEG_NAMES).index(l) if l in LEG_NAMES else 99)
if not ran:
    print("No results: no r-* artifact was uploaded (see the jobs' logs).\n")
else:
    print(f"This run: {', '.join(LEG_NAMES.get(l, l) for l in ran)}. "
          "Jobs of the checks it does not run show as skipped.\n")
for probe in ("cb", "vf", "nn"):
    if (probe, "base", 0) in jobs:
        d = jobs[(probe, "base", 0)]
        o = origin(d)
        print(f"- base {probe}: {summary(d)} ({read(os.path.join(d, 'rev.txt')).split(' ', 3)[-1].strip()})" +
              (f"; {o}" if o else ""))
for leg in SHARDED:
    dirs = shard_dirs(leg, "base")
    if dirs:
        line, _, notes = probe_tree(leg, "base")
        rev = read(os.path.join(dirs[0][1], "rev.txt")).split(" ", 3)[-1].strip()
        print(f"- base {leg} ({nshards(dirs)}): {line} ({rev}); {probe_origin(dirs)}" +
              "".join(f"\n  - {x}" for x in notes))
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
    for leg in SHARDED:
        if not shard_dirs(leg, n):
            continue
        line, h, notes = probe_tree(leg, n)
        out = f"- {leg} ({nshards(shard_dirs(leg, n))}): {line}"
        if shard_dirs(leg, "base"):
            _, b, _ = probe_tree(leg, "base")
            both = sorted(set(b) & set(h))
            hs = {(k, i) for k in both for i in h[k]}
            bs = {(k, i) for k in both for i in b[k]}
            # a brow case's id is its shard's own; a corpus finding is named by its file
            show = (lambda k, i: f"shard {k}: {i}") if leg == "brow" else (lambda k, i: i)
            if not both:
                out += "; vs base: no shard finished on both sides"
            elif hs == bs:
                out += "; same findings as base"
            else:
                out += f"; vs base: {len(hs - bs)} new, {len(bs - hs)} gone"
            if both and len(both) < max(len(b), len(h)):
                out += f" (over shards {', '.join(map(str, both))})"
            for k, i in sorted(hs - bs)[:20]:
                out += f"\n  - new: {show(k, i)}"
            for k, i in sorted(bs - hs)[:20]:
                out += f"\n  - gone: {show(k, i)}"
        for x in notes:
            out += f"\n  - {x}"
        print(out)
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
        # the cost tools (#7501): each one's summary line, then its detail
        for f, tag in (("repr_diff.txt", "representation"), ("c_costs.txt", "C costs"),
                       ("alloc_diff.txt", "allocations")):
            lines = read(os.path.join(d, f)).rstrip().splitlines()
            if not lines:
                continue
            print(f"- {tag}: {lines[0]}")
            # the strongest signal on its own line
            for l in lines[1:]:
                if l.startswith("a new O(len) operation") and not l.endswith(": none"):
                    print(f"- **{l}**")
            if len(lines) > 1:
                print("  ```text\n" + "\n".join("  " + l for l in lines[1:61]) +
                      ("\n  ..." if len(lines) > 61 else "") + "\n  ```")
    if ("cident", n, 0) in jobs:
        # cident-leg.sh: the two pasteable lines, then each flavour's
        # cident.sh line and the programs it reported
        d = jobs[("cident", n, 0)]
        lines = read(os.path.join(d, "cident.txt")).rstrip().splitlines()
        if not lines:
            print(f"- {read(os.path.join(d, 'cident-missing.txt')).strip() or 'cident: no result (see cident-*.log)'}")
        else:
            print("- cident:\n  ```text\n" + "\n".join("  " + l for l in lines[:62]) +
                  ("\n  ..." if len(lines) > 62 else "") + "\n  ```")
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
    # the gate leg, and pgate's finish in the same files (gate_apply.py and
    # file1.py read either under "### gate:")
    for leg in ("gate", "pgate"):
        if (leg, n, 0) not in jobs:
            continue
        d = jobs[(leg, n, 0)]
        meta = dict(line.split("=", 1) for line in read(os.path.join(d, "gate-meta.txt")).splitlines() if "=" in line)
        status = meta.get("status", "FAIL")
        if status not in ("PASS", "FAIL", "CONFLICT"):
            status = "FAIL (incomplete)"
        print(f"\n### gate: {status}\n")
        print(f"Master: `{meta.get('master', 'unknown')}`; merged: `{meta.get('merged', 'unknown')}`; "
              f"exit status: {meta.get('exit_status', 'unknown')}.\n")
        if meta.get("mode") == "pgate":
            times = [l for l in read(os.path.join(d, "gate.log")).splitlines() if l.startswith("[pgate] part times: ")]
            print(f"Parallel gate (pgate): `make gate`'s legs as parts {meta.get('parts', '?')} on the merged tree." +
                  (f" {times[-1][8:]}." if times else "") + "\n")
        if meta.get("target", "gate") != "gate":
            print(f"Smoke target: `{meta['target']}` (not a full gate run).\n")
        lines = read(os.path.join(d, "gate-summary.txt"))
        print("```text\n" + lines + ("" if lines.endswith("\n") else "\n") + "```")
        if status.startswith("FAIL"):
            log = read(os.path.join(d, "gate.log")).splitlines()
            errors = [line for line in log if re.search(r"error|fail|\*\*\*|gate:", line, re.I)]
            targets = re.findall(r"\*\*\* \[([^]\n]+)\]", "\n".join(log))
            print(f"\nFailing leg/target: {', '.join(dict.fromkeys(targets)) or 'unknown (see log below)'}.\n")
            print("```text\n" + "\n".join((errors or log)[-20:]) + "\n```")
    missing = [f"{l} {k}" if k else l for (l, nm, k) in
               [(l, nm, k) for (l, nm, k) in jobs if nm == n] if not os.listdir(jobs[(l, nm, k)])]
    if missing:
        print(f"- empty artifacts: {', '.join(missing)}")
    print()

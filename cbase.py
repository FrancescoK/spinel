#!/usr/bin/env python3
# The base side of the corpus C diff, kept between runs.
#
# usage: cbase.py plan TREE PROGRAMS CACHE RECOMPUTE
#        cbase.py manifest TREE CACHE
#
# CACHE/c/<program>.c holds what the base compiler printed for <program>
# (`-S --no-line-map`, stdout and stderr, as cdiff1.sh reads it), compiled
# in a head's tree at the same path this run compiles in. CACHE/manifest.json
# records every file under test/ and benchmark/ of that tree by its hash.
#
# `plan` writes to RECOMPUTE the programs of PROGRAMS (paths relative to TREE)
# whose cached C cannot stand for this tree, and prints one line saying how
# many it kept. A program is compiled again when:
#   - there is no cache, or no C for it in the cache;
#   - it differs from the cached tree's copy, or is new;
#   - a file under test/ or benchmark/ other than a program or an .expected
#     file differs (a required file, an .rbs beside a test, ...): then every
#     program is, since which program reads which such file is not known;
#   - it names a program that differs (a require of it), or such a name appears
#     in any non-program file (then every program is);
#   - it reaches outside its own directory by a path (`../`, `./`, __dir__,
#     the load path), which may read a file of the head's tree that the
#     manifest does not cover.
# spinel resolves a require from literals beside the requiring file or from
# its own lib/, which is the base's and fixed by the cache key, so a file a
# program reads is a file under test/ or benchmark/ or it is caught above.
#
# `manifest` records TREE into CACHE/manifest.json.
import hashlib, json, os, re, sys

PROG = re.compile(r"(test|test/infer|benchmark)/[^/]+\.rb$")
RISKY = re.compile(rb"\.\./|[\"']\./|__dir__|\$LOAD_PATH|\$:")

def tree_files(tree):
    out = {}
    for top in ("test", "benchmark"):
        for root, dirs, files in os.walk(os.path.join(tree, top)):
            for f in dirs + files:
                p = os.path.join(root, f)
                rel = os.path.relpath(p, tree)
                if os.path.islink(p):
                    out[rel] = "link:" + os.readlink(p)
                elif f in files:
                    with open(p, "rb") as fh:
                        out[rel] = hashlib.sha256(fh.read()).hexdigest()
    return out

def read(path):
    with open(path, "rb") as fh:
        return fh.read()

def plan(tree, programs_path, cache, recompute_path):
    programs = [l.strip() for l in open(programs_path) if l.strip()]
    redo, why = list(programs), None
    try:
        with open(os.path.join(cache, "manifest.json")) as fh:
            old = json.load(fh)["files"]
    except (OSError, ValueError, KeyError):
        old, why = None, "no cache"
    if old is not None:
        cur = tree_files(tree)
        changed = {p for p in set(old) | set(cur) if old.get(p) != cur.get(p)}
        aux = [p for p in cur if not PROG.match(p) and not p.endswith(".expected")]
        aux_changed = sorted(p for p in changed if not PROG.match(p) and not p.endswith(".expected"))
        stems = {os.path.basename(p)[:-3].encode() for p in changed if PROG.match(p)}
        named = next((p for p in aux if not cur[p].startswith("link:") and
                      any(s in read(os.path.join(tree, p)) for s in stems)), None) if stems else None
        if aux_changed:
            why = f"{len(aux_changed)} non-program files differ from the cached tree (first {aux_changed[0]})"
        elif named:
            why = f"{named} names a program that differs from the cached tree"
        else:
            redo = []
            for p in programs:
                if p in changed or not os.path.isfile(os.path.join(cache, "c", p + ".c")):
                    redo.append(p)
                    continue
                src = read(os.path.join(tree, p))
                if RISKY.search(src) or any(s in src for s in stems):
                    redo.append(p)
    with open(recompute_path, "w") as fh:
        fh.writelines(p + "\n" for p in redo)
    kept = len(programs) - len(redo)
    print(f"base C: {kept} of {len(programs)} programs from the cache, {len(redo)} compiled" +
          (f" ({why})" if why else ""))

def manifest(tree, cache):
    with open(os.path.join(cache, "manifest.json"), "w") as fh:
        json.dump({"files": tree_files(tree)}, fh)

if __name__ == "__main__":
    if sys.argv[1:2] == ["plan"] and len(sys.argv) == 6:
        plan(*sys.argv[2:])
    elif sys.argv[1:2] == ["manifest"] and len(sys.argv) == 4:
        manifest(*sys.argv[2:])
    else:
        sys.exit(__doc__ or "usage: cbase.py plan TREE PROGRAMS CACHE RECOMPUTE | manifest TREE CACHE")

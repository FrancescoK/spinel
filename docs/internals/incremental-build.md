# Incremental builds: the unit split and the object cache

`spinel --incremental prog.rb` is a development build. It generates the whole
program's C as always, cuts the C into units, takes the object of every unit
whose text did not change from a cache, compiles the rest in parallel and
links. An edit that keeps its types recompiles one unit; here, a literal
changed in one method of the 26,000-line scale program (`sh
test/scale/gen.sh 400`):

```
$ spinel --incremental --cache-stats s400.rb
spinel: cache: units=79 hit=78 miss=1 rt=4/4 program=6/6 tagged=68/69 dir=/home/me/.cache/spinel
spinel: cache: miss g031 unit_a96c8ae3d464ed77.c (133864 bytes)
```

A build without `--incremental` is untouched: the same C, byte for byte, and
the same binary. The release build is still the single translation unit;
what `--incremental` gives up for its speed is under "What differs from a
release build" below.

## Summary

**Regenerate all the C on every build, and cache the objects of the units
whose text did not change.** Regenerating only the C of the edited file is
not sound here. `require` splices every file into one parse, and inference
runs over the whole program: a method's C depends on the argument types its
callers pass, on the return and ivar types of what it calls, on the dispatch
tables, the class ids and the symbol ids. An edit in one file changes the C
of methods in another, and a build that kept the old C of an unedited file
would link code typed for a program that no longer exists, without a word.
So the frontend runs in full every time, and "did this change" is asked of
its output. Crystal, Nim, mypyc and Vala made the same choice for the same
reason; the C or LLVM compilers that got fast rebuilds all got them on the
backend side.

Why the backend is worth caching, measured for the design (2026-10-17,
4-core Linux, gcc 13.3, `-O2`) on the scale program of `test/scale/gen.sh`:

- `sh test/scale/gen.sh 400` (26,000 lines of Ruby, 9.3 MB of C) built in
  79 s, of which `cc` was 44 s on 4 cores; the 6,500-line `gen.sh 100`
  built in 32.6 s, of which `cc` was 28.4 s.
- A method-body edit that keeps its types changes **2 lines** of the
  167,642 lines of C; an edit that turns a return type from Integer to
  Float changes 18 (stage 1 below brought that down from 8,418).
- A translation unit that includes the runtime header and nothing else
  takes 0.6 s at `-O2`. That fixed cost is why a unit is a few hundred KB
  of C and not one method: s400 has 8,813 function definitions, which
  would be 88 minutes of header alone.

The frontend is not made incremental here. On the largest program measured
(`gen.sh 1600`, 104,000 lines) it was 740 s of a 1,022 s build, and it grows
faster than the input; that is a separate problem with its own design.

## Stage 1: deterministic names (merged)

A cache keyed by a unit's text hits only if an edit leaves the text of the
other units alone, and the generated C used to be full of program-wide
counters: one temp more in one method renumbered every temp after it. Stage 1
(207bf789e and before) made each name depend on the function it is in:

| name | now |
|---|---|
| expression temps `_tN`, barrier temps `_wbN` | `unit_begin()` restarts the count at each method, constructor, dispatcher, `END` block and `main` |
| `_proc_N`, `_fib_cap_N`, `_fiber_body_N`, `_capv_N`, ... | `uid_new()` returns `<unit tag>_<n>` (`_proc_Model200_label_1`); a tag begun twice gets `_dN` |
| frozen literals `_fzl_N` | `_fzl_<hex>`, an FNV-1a hash of the escaped text; a hash collision is `_fzl_<hex>_<n>` in order of appearance |
| split-out dispatchers `sp_pd_N` | `sp_pd_<hex>`, a hash of what they dispatch (method name and C signature), so a changed arm does not rename the callers' call |
| `comp_node_ord` names (`__fwdc_N`, `x__bpN`, ...) | `comp_node_pbases()` numbers each node within its enclosing `def` or class, as builtins' nodes already were |
| `#line` | still written; the unit hash leaves the line markers out (below) |

What stays program-wide, and why each is a legitimate miss rather than a
bug: class ids and symbol ids are the program's own numbering, and a unit
that uses a class or a symbol must change when it does. New ones are appended,
so existing ids do not move. The regexp slots `sp_re_pat_N`, the `_dN` and
`_<n>` collision suffixes and the `g_hc_seq` names are still in order of
appearance; adding one ahead of others renames the rest. They are rare, and
fixing each changes the default output (follow-ups).

`tools/unit_stability.sh` (`make unit-stability-test`) holds this in place:
it makes three edits to the middle of `gen.sh 400` and bounds the diff of
the default C (edits a and b: 2 lines, c: 18).

One more counter was found later, by `make incremental-test`: the write
barriers are spliced into the finished C in one pass over the whole program,
and their temps continued from `main`'s last temp, so one temp more in
`main` renamed every barrier in the program. Under `--incremental` the count
now restarts at each function the pass splices (34245bcab); the default
build keeps its numbering, so its C is unchanged.

## Stage 2: the unit split and the object cache

### The pipeline

```
prog.rb ─ parse ─ analyze ─ codegen ─ C with `#pragma spinel unit <tag> <group>` lines
        ─ cc -E (the build's own flags) ─ pre.i
        ─ c_split_units (src/csplit.c) ─┬─ sp_rt.h      (+ sp_sys_rt<n>.h)    the runtime
                                        ├─ sp_program.h (+ sp_sys_prog<n>.h)  the program's types and inline helpers
                                        ├─ unit_<h16>.c × N   rt00.. p00.. g000.. x_<group>_<s>
                                        └─ units.txt          link order, hashes
        ─ a key per unit ─┬─ hit:  the cached object, hard-linked into the work dir
                          └─ miss: cc -c, in parallel
        ─ link the objects in units.txt order ─ store the misses ─ binary
```

The design document drew this differently: codegen writing a units directory
itself, with one header of types and per-unit declarations. Two things moved
it after the preprocessor. `lib/spinel_rt.h` defines file-scope objects and
static functions in every unit that includes it, so a split before `cc -E`
would need a multi-TU mode of the runtime header, plus a C lexer for raw
comments, attribute macros and `SP_POOL_DEFINE(X)` statements. And the
preprocessed text is what a cached object depends on, system headers and
compiler-defined macros included, so a hash of it is most of a sound cache
key. `src/csplit.c` already read preprocessed C for the `--jobs` split; its
lexer (`cs_lex`) is shared by both splits, and the `--jobs` split's output is
unchanged.

### The pragma, and why only under the flag

A unit boundary has to survive `cc -E`, which drops comments. A line marker
would be rewritten by the line map and rename diagnostics. `#pragma spinel
unit <tag> <group>` passes through gcc 13 and clang 18 verbatim on a line of
its own, and every pass that rewrites the whole C text (the barrier splice,
the line map, `poll_pure_split`, `main_body_split`) copies `#` lines as they
are.

`unit_begin_in()` (`src/codegen_util.c`) writes it where a method, a
constructor, the dispatchers, an `END` block or `main` begins, into the body
and also into `g_procs` and `g_proc_protos`: a method's procs, fiber bodies,
capture structs and their prototypes are spliced ahead of every body, and
would otherwise lose their method. The **tag** is the unit tag stage 1
already had (the method's C name without `sp_`, `new_<Class>`, `dispatch`,
`main`). The **group** is what units are packed by: `<file key>__<Class>`
for a class's methods and constructor, `<file key>__top` for top-level
methods, `dispatch` for both dispatcher tags, `main` for `END` blocks and
`main`. The file key is the file's base name without its extension and six
hex digits of a hash of its path relative to the main file's directory, so
the same program spelled `app.rb` or `/abs/dir/app.rb` packs the same way.
The same source under another file name does not: every tagged unit misses
once, so build an edited program from the path it was built from. `#pragma
spinel unit prog prog` ends a tagged stretch, so the display hooks, `int
main`, the pd prototypes and the pd definitions do not inherit the last
tag.

The pragma is written only when the driver called
`unit_incremental_set(1)`. The default C has to stay byte-identical, and a
setter rather than an environment variable keeps the mode out of the
environment of `cc` and of a program run under `-E`.

### Two regions

The **runtime region** is everything before the return from `#include
"spinel_rt.h"`: the first line marker that enters a file named `spinel_rt.h`
(flag 1), then the first marker after it that returns to the main file
(flag 2). The entry is found first because clang, unlike gcc, returns to the
main file once before that, from its `<built-in>` block. Everything after is
the **program region**, whatever file a marker names (`.rb` files,
`<spinel-synthesized>`, `sp_cext.h`). The split declines without both
markers.

The runtime region does not depend on the program, only on the TU-head
defines, the flags and the compiler, so its units are shared by every
program built the same way: `test/fiber_kill.rb` and the 26,000-line scale
program produce the same four rt unit files.

### Where each item goes

| region | item | goes to |
|---|---|---|
| runtime | types, typedefs, system-header items | `sp_rt.h` verbatim (system-header items in `sp_sys_rt<n>.h` side files, so cc keeps them quiet, #8579) |
| runtime | `static inline` function | `sp_rt.h` verbatim; the ones with a static local are demoted to one definition, as in the `--jobs` split |
| runtime | other function | a prototype in `sp_rt.h` where it stood; the definition, without `static`, in an rt unit |
| runtime | variable | `extern` in `sp_rt.h` where it stood; the definition in the rt unit of its defining occurrence |
| program | untagged type, typedef, struct, `_Static_assert`, native `extern` | `sp_program.h` |
| program | untagged inline helper | `sp_program.h` verbatim, after the declarations it uses (pinned, below) |
| program | tagged typedef (a proc's or fiber's capture struct) | its tag's unit: an anonymous struct typedef cannot be declared anywhere else |
| program | function, prototype, variable | a declaration-table entry, and the definition in its home unit |

`sp_program.h` includes `sp_rt.h` and holds no method prototype, no `extern`
of a program variable and no non-inline function body; those reach a unit
only through its import list. `make incremental-test` checks that on a kept
directory.

### Packing

`--unit-bytes=N` (default `256K`) is the target size of a unit, in bytes of
preprocessed text without line markers and blank lines. Three streams are
packed, each by a rule that is a function of the text alone:

- **rt units** (`rt00`, `rt01`, ...): the runtime's functions and variables
  in text order, a unit closing when it reaches the target. Four units at
  256K today.
- **program units** (`p00`, ...): the untagged program items, the frozen
  literals, symbol tables and variables. `ceil(W / U)` buckets, an item's
  bucket chosen by a hash of its **family**: every `_fzl_` literal is family
  `fzl`, the symbol tables `sym`, the regexp slots `re`, the Bigint literals
  `bigl`, anything else its own name. Adding a literal then misses the one
  `fzl` bucket, not a random one per literal.
- **tagged units**: the groups whose weight is at most the target share
  `ceil(W / U)` buckets (`g000`, ...), a group's bucket chosen by a hash of
  its name. A group over the target gets units of its own, `ceil(w / U)` of
  them, a tag's unit chosen by a hash of the tag (`x_<group>_<s>`). Every
  segment of one tag stays in one unit, so a capture typedef is never apart
  from the functions that use it, and a single tag heavier than the target
  stays whole: on s400, `x_dispatch_00` is 884 KB and `x_main_00` 698 KB.

The hash is Lamping and Veach's jump consistent hash. Parallel compiles make
the size of one unit cheap and locality cheap, so the thing to avoid is a
boundary that cascades: packing in order by size moves every later boundary
when one method grows, and a power-of-two bucket count reshuffles every unit
when the program crosses a threshold. With the jump hash, a bucket count that
grows by one moves about 1/B of the groups. A program whose weight sits just
at a multiple of the target can see a missed unit or two more on alternate
builds; that is the cost.

Empty buckets are not units. On s400 at 256K this gives 79 units: 4 rt, 6
program, 67 common tagged and the two over-cap ones above. A small test
program gives 6 (4 rt, 1 program, 1 tagged).

### The declaration table and the import list

The table has one entry per program-region name a unit may use without
defining it: a function's prototype (its first prototype in text order, or
its definition's head, with `static` and `inline` removed), and one `extern`
per declarator of each variable. A unit's **import list** is the entries
whose names appear in its own items as identifiers, outside string and char
literals. Each entry is written just before the first item of the unit that
names it, in table order; ahead of everything would be simpler, but the
dispatch unit's inspect tables are typed by typedefs that are themselves
items of that unit. The original translation unit declared the name before
its first use, so that position is always late enough.

This is what keeps an edit local: a unit's text is its own items plus the
declarations of what they use, so adding a method changes the units that
define and call it, and a changed signature misses its callers, which is the
recompilation that has to happen. An entry is not transitive: a prototype or
an `extern` names only types, and the types are in the headers.

An untagged inline helper written into `sp_program.h` may use a function or
a variable the header does not declare; those entries are written just
before it, **pinned**, and left out of every import list. That position is
valid for the same reason as above. A `struct { ... }` with no tag is a
different type in each declaration that spells it, so such a variable's
`extern` and definition both name a tag made from the variable's name,
`sp__anon_<name>`, never a counter that would depend on what came before.

### Variables: the defining occurrence

A variable can be declared more than once: `SP_POOL_DECLARE(X)` in a proc's
prototype segment is a tentative definition, and `SP_POOL_DEFINE(X)` in the
constructor initialises it. Under gcc's default `-fno-common`, two units
each defining it would not link. Of a name's occurrences in text order, the
first with an initialiser is the **defining occurrence**, or the first one
when none has; the definition goes to that occurrence's unit, without
`static`, and the others are dropped. A literal object is defined once (in
the `fzl` bucket) and reached through `extern` everywhere else, so two equal
literals in two units are still one object.

### `_sp_gcr_` renumbering

`SP_GC_ROOT` names its guard `_sp_gcr_<__COUNTER__>`, and `__COUNTER__` runs
across the whole translation unit: one root added near the top would change
every function after it. While a function's text is written (into a unit, or
as an inline body into either header), every `_sp_gcr_<digits>` is renamed
`_sp_gcr_<k>`, counting from 1 per function in order of first appearance,
token by token so that a string literal is never touched. `sp_gc.h` holds
the only `__COUNTER__` uses in lib/ (`sp_compat.h` mentions it in a
comment); `make incremental-test` checks both.

### Line markers, unit names and the manifest

Units keep the preprocessor's line markers, so a warning or an error in a
unit names the `.rb` line and a system header stays quiet, as in the `--jobs`
parts. The temp C's name has the pid in it; every marker that names it is
rewritten to `"spinel_program.c"` before anything is read, so no pid reaches
a header or a unit.

A unit's **hash** is the SHA-256 of the file as written with its line
markers removed, unless `-g`/`--debug` is on, where the markers stay in: a
line shift must miss there, since the line table is in the object. Without
`-g` the markers cannot reach the object (nothing in the runtime or the C
uses `__LINE__` or `__FILE__`), so an edit that only moves later lines
misses nothing. The file is named `unit_<first 16 hex of hash>.c`: the same
text compiles under the same name in every build, and the name is in the
object (gcc's `STT_FILE` symbol). Two units with one name decline the split.

`units.txt` lists the header hashes and then each unit in link order:

```
rt_hash 9a085551056371fe917830db32afe79a407b09cd23406f73302f7393ae38dab5
program_hash dac3ce6dc14c0e71c90f8a6681caabba75a8322cdc0a530f1b7c1a0dcb2ec5a8
rt00 unit_8de94b95a22d71c3.c 8de94b95...aa678919 rt 264092 -
p00 unit_fd3705ccbf3028f8.c fd3705cc...65dc4eb9 program 26523 -
g000 unit_374a0dcda85fe71f.c 374a0dcd...1a2b24c6 tagged 18283 main
```

(label, file, hash, kind, marker-free bytes, groups; hashes shortened here).
`rt_hash` covers `sp_rt.h` and its side files, `program_hash` `sp_program.h`
and its side files: a C-extension program's `<ruby.h>` lands in such a side
file and has to be in the key. Both are computed without line markers, as
unit hashes are; otherwise adding one literal, which shifts the markers of
every header item after it, would miss every program unit.

### The key

A unit's key is the SHA-256 of these lines:

```
spinel-unit-1          format
<ccid>                 SHA-256 of `cc --version`, `cc -dumpmachine`, `cc -v 2>&1` and `uname -sm`
<flags>                the compile command up to the source, verbatim: -O, -m32, -I..., -DSP_THREADS, -g, ...
<rt_hash>
<program_hash>         program and tagged units only: an rt unit includes sp_rt.h alone
<unit hash>
```

Each covers an input of `cc -c`: the unit's text, the headers it includes
(as preprocessed text, so every lib and system header and the TU-head
defines are in it), the compiler, the flags. `cc -v` tells apart two
compilers of one version configured differently (a default PIE, another
install); `uname -sm` keeps one kind of machine's objects from another's.
A cache shared over a network file system by hosts with different compilers
or CPUs is not a supported setup: a compiler wrapper that adds
code-generation flags `--version` does not show would alias their keys.

Not in the key: the spinel revision (the key covers the text the compiler
sees; a different revision that writes the same unit gets the same object by
construction), the runtime archive (an object does not depend on it, and the
link always uses the current one), and the flags the unit compile adds,
which are constant or a function of the unit hash.

### The cache

```
<cache>/objects/<key[0..2]>/<key[0..32]>.o            an object
<cache>/objects/<key[0..2]>/<key[0..32]>.o.tmp.<pid>  a store in progress
<cache>/objects/.pruned                                when the last prune ran
```

`<cache>` is `SPINEL_CACHE_DIR`, else `$XDG_CACHE_HOME/spinel`, else
`$HOME/.cache/spinel` (`%LOCALAPPDATA%\spinel` on Windows). None of them: the
cache is off for the build, every unit a miss.

- **Lookup**: an object of size 0 is a miss and is removed; otherwise it is
  hard-linked into the work directory (copied, with the byte count checked,
  where a hard link fails) and its time is touched, so a hot object stays
  young.
- **Store**: after the link succeeded, each compiled miss is linked or
  copied to `<key>.o.tmp.<pid>` and renamed over `<key>.o`. A copy is
  renamed only when it is complete. Nothing from a failed build is stored,
  and a failed store is reported under `--cache-stats`, never an error.
- **Eviction**: a link that fails after a hit unlinks every hit of the
  build before falling back, so a corrupt or foreign object costs one
  fallback, not every build after it.
- **Prune**: at most once a day, objects untouched for `SPINEL_CACHE_DAYS`
  (14) days and stale `.tmp.` files go.
- **No claims.** Two builds that miss the same unit at once both compile it
  and both store it; the second rename replaces the same bytes. That wastes a
  few seconds of a concurrent cold build and never makes one process wait
  for another. A claim scheme is left for when `spin test` fans builds out.

An s400 cache holds 23 MB after its first build and three edits (83
objects).

| variable | meaning |
|---|---|
| `SPINEL_CACHE_DIR` | the cache root |
| `SPINEL_NO_CACHE=1` | compile every unit; no lookup, store or prune (the from-scratch comparator) |
| `SPINEL_KEEP_UNITS=1` | keep the work directory and print `spinel: units kept at <dir>` |
| `SPINEL_INCREMENTAL_STRICT=1` | a decline or a failed unit or link fails the build instead of falling back |
| `SPINEL_CACHE_DAYS` | the prune age in days (14) |
| `SPINEL_UNIT_DROP_DECL=<name>` | internal, for the gate: leave one declaration out of the table |

`SPINEL_SPLIT_STRICT` and `SPINEL_KEEP_SPLIT` keep their `--jobs` meaning and
do not affect `--incremental`.

### The compile and the link

The misses compile `--jobs` at a time (default min(cores, 16), at most 64;
`--jobs=1` is serial; without `fork`, one at a time through `system()`):

```
<flags> -Werror=implicit-function-declaration -Werror=implicit-int -frandom-seed=<unit hash> \
        [-fdebug-prefix-map=<work>=spinel-units] -c '<work>/unit_<h16>.c' -o '<work>/unit_<h16>.o'
```

The two `-Werror` flags are what make a declaration the import scan missed a
compile error: spinel compiles with `-Wno-all`, under which gcc 13 compiles a
call to an undeclared `sp_int` function as returning `int`, silently, and
that object would go into the cache. `-frandom-seed` removes the one source
of nondeterminism gcc documents; the prefix map, under `-g` only, keeps the
work directory out of cached debug info. The link repeats the flags, lists
the objects in `units.txt` order and appends the rest of the original
command (the archives, `-lm`, `--gc-sections`, `-o`). A hit and a miss put
the same object in the same place, so a warm build links the binary a
from-scratch build links.

### The fallback

When the incremental path cannot finish, one line says why and the single
unit compiles instead, as a failed `--jobs` split already does:

```
spinel: incremental: <reason>; compiling as one unit
```

The reason is `the preprocessor failed`, `the unit split declined`, `unit
<label> did not compile` (after that unit's own diagnostics, which name the
`.rb`), `the link failed`, or `cannot create a work directory (...)`. Under
`SPINEL_INCREMENTAL_STRICT=1` the line ends in `; STRICT, failing` and the
build fails. Falling back after a unit compile error doubles the cost of a
build that fails anyway; it is kept while the splitter is new, so that
`--incremental` never fails where the plain build succeeds, and the gate runs
STRICT so that a splitter regression cannot hide behind it.

Every gap in the split is loud. A missing declaration is a compile error (the
`-Werror` flags). A name defined twice is a link error, which evicts the
hits. Two declarations with different types are a conflicting-types error. A
typedef apart from its users is an incomplete-type error. An item the lexer
does not read declines before anything compiles. None of them produces an
object that links into a wrong program.

## What differs from a release build

1. Functions are external and the program is many translation units, so
   nothing is inlined across units and there is no whole-program IPA. The
   `--jobs` split already does this, and it cost optcarrot about 10%, which
   is why a small program is not split unless asked.
2. Short methods lose their inline hint (`method_inline_hint` and
   `method_inline_force` answer no, as under `--debug`): a `static inline`
   method would need its body in every unit that calls it. Besides the
   pragma lines and the barrier temps' numbering, this is the one difference
   in the C itself; the inline helpers of the header region stay inline in
   `sp_program.h`.
3. The runtime's `static inline` functions that have a static local are
   demoted to one definition, as in the `--jobs` split.
4. Literals, regexp slots, class variables, globals, constants and pool
   state are defined once and reached through `extern`: one object, one
   identity, as before.

`--incremental` is a development-build mode: release builds, benchmarks,
optcarrot and the test corpus do not use it.

## Verifying it

**`make incremental-test`** (`tools/incremental_test.sh`, a `gate-props`
leg) builds `gen.sh 30` with `SPINEL_INCREMENTAL_STRICT=1`, so the fallback
cannot hide a split that is wrong. It compares every warm build with a
`SPINEL_NO_CACHE=1` build of the same source byte for byte, and bounds the
misses of six edits to one class:

| edit | bound | missed (of 11) |
|---|---|---|
| a literal in a method body | 2 | 1 |
| a constant a method returns | 1 | 1 |
| a return type, Integer to Float | 6 | 2 |
| a method added, and called | 3 | 1 |
| a literal added | 2 | 2: the class's unit and the `fzl` bucket |
| an instance variable added | every rt unit hits | 7: every program and tagged unit |

A method added and never called does not reach the C, so the edit also
calls it. The leg also checks the refused flags, that the default C has no
pragma, two cold builds, a no-op rebuild, `--jobs=1`, an unwritable cache,
the shape of a `-c --incremental` directory, over-cap groups at
`--unit-bytes=32K` with a Fiber and capturing blocks, a planted missing
declaration (a compile error under STRICT, the fallback without), one unit's
object compiled in two other directories, fifteen corpus builds cold and
warm, two builds racing on one empty cache, and the prune. It takes about 5
minutes on 4 cores.

**`make incremental-bench`** (`tools/incremental_bench.sh`, not a gate leg)
prints wall times, units and misses for the plain, `--jobs` and
`--incremental` builds of the scale program, cold, after each edit and as a
no-op, at 256K and 512K; `INCREMENTAL_BENCH_K` picks the programs (default
100 and 400). The K=100 table is in
[profiling.md](../profiling.md#incremental-builds). In short: on a 4-core VM,
the plain build of `gen.sh 100` took 40.3 s, a cold incremental build 34.9 s
and a warm one after a one-unit edit 15.9 to 17.3 s, about 14 s of which is
the frontend. 256K was faster than 512K on every warm edit there, so it is
the default. The bench has not been run at K=400; separate runs of s400 on
the same machine took 205 s cold and about 137 s warm after a one- or
two-unit edit, of which the frontend was about 125 s and `cc_total` about
4.5 s. That machine is slower than the one the design measured on, which
ran the s400 frontend in 35 s.

**`--cache-stats`** prints, after the build, `units=N hit=H miss=M` (the
stable prefix tests read), the hits per kind (`rt=4/4`: four of four rt
units hit), the cache directory or `off (<reason>)`, then one line per miss with
its label, file and size, and `store failed (...)` or `evicted K objects`
when either happened. A warm build that misses every program and tagged unit
but no rt unit changed something in `sp_program.h` (an ivar, a class); one
that misses the rt units too changed the compiler, the flags or a header.

**`--timing`** shows, inside `cc_total`: `cc_preprocess`, `cc_split` (split,
write and hash), `cache_lookup`, `cc_compile ms=... units=N miss=M jobs=J`
and `cc_link`. A warm rebuild of a small program:

```
spinel-timing: phase=cc_preprocess ms=115.4
spinel-timing: phase=cc_split ms=77.1
spinel-timing: phase=cache_lookup ms=14.0
spinel-timing: phase=cc_compile ms=0.0 units=6 miss=0 jobs=4
spinel-timing: phase=cc_link ms=172.1
spinel-timing: phase=cc_total ms=381.1
```

**`SPINEL_KEEP_UNITS=1`** keeps a build's work directory: the units, the
headers, `units.txt` and the objects. **`spinel -c --incremental app.rb [-o
DIR]`** writes the unit set to `DIR` (default `app.units`) without compiling
it: `program.c` (the C with its pragmas), `sp_rt.h`, `sp_program.h`, their
side files, `unit_*.c` and `units.txt`. Two such directories of one source
are identical (`diff -r`), and each unit compiles on its own with the line
above. A second run into the same directory removes the unit files the new
manifest does not list.

## Follow-ups

- **spin**: `--incremental` for `spin build`/`run`/`test`, behind a variable
  first, with `spin build --release` for the single unit and `spin clean
  --cache` for the object cache. `spin` does not use it yet.
- **A no-op detector**: skip the frontend when the hash of every input is
  unchanged. Warm builds are frontend-bound now, so this is the next large
  saving, most of all for `spin test`.
- **Claims** for concurrent cold builds (a `.busy` file per key with a pid,
  stale detection, a bounded wait), once `spin test` builds in parallel.
- **A binary cache**: skip the link when every key and the link line match.
- **No fallback on a unit compile error**, once the corpus has run STRICT
  without a splitter failure.
- **Per-class pragmas** for the header region's class items (`sp_X__gc_scan`,
  `civ_`, `cst_`, the ivar renumbering) and per-class type blocks in
  `sp_program.h`, so an ivar or a class added misses less than every program
  unit.
- **Content names** for `sp_re_pat_N`, the `_dN` and `_<n>` suffixes and the
  `mc_resolve_clashes` suffixes, and a per-unit reset of `g_hc_seq`; each
  changes the default C and is its own small change.
- **Windows**: parallel compiles through the shim's process spawner instead
  of serial `system()`; the cache path is untested there.
- `--target=wasm32-wasi` stays a single unit, and a split before the
  preprocessor is not planned.

# Profiling a Spinel program

Two measurements, both opt-in and both usable on a normal build: where the time
goes, and where the allocations come from. Neither needs a special compiler and
neither costs anything when it is off.

Before measuring anything, `spinel-doctor app.rb` is the static half of the
same question: its `advice` leg lists the source lines that compile to boxed
dispatch inside loops -- the usual suspects -- without running the program (see
[`tools/README.md`](../tools/README.md)). The profiler below then tells you
which of those actually cost time.

## Where the time goes: `--profile`

```
spinel app.rb --profile -o app
perf record -g ./app
perf report
```

`--profile` builds the same `-O2` binary the default build produces, plus the
three things a sampling profiler needs: `-g`, `-fno-omit-frame-pointer`, and an
unstripped symbol table. It also writes `app.symbols.json` beside the binary --
the `--emit-symbol-map` payload, mapping each emitted C symbol back to the Ruby
name it came from (`sp_PPU_render_pixel` → `Optcarrot::PPU#render_pixel`).

Methods compile to `static` C functions, so a stack walk names them only when
the symbol table is present; that is what `--profile` keeps. If `perf` is
unavailable -- `perf_event_paranoid` is locked down on many CI and hardened
hosts -- any sampler that reads frame pointers works the same way.

### Reading the result

`perf report --stdio --no-children` gives self time per function, which is
usually the first question:

```
84.80%  sp_Interp_visit
 8.49%  sp_StrIntHash_get_opt
 1.82%  __memcmp_evex_movbe
```

`perf script` gives whole stacks, and with `-g` the inlined frames come back
too -- a helper the C compiler folded into its caller still appears by name:

```
    sp_str_byte_len+0x68f (inlined)
    sp_String_append_bin+0x68f (inlined)
    sp_gen_text+0x68f
    main+0x68f
```

Fold those into one line per stack (`a;b;c count`) for a flamegraph renderer.
`app.symbols.json` turns the C names in them back into Ruby ones.

Two things to expect. Kernel frames stay unresolved unless
`/proc/sys/kernel/kptr_restrict` allows otherwise, which does not affect
anything above. And a build that discards unwind information reports no
usable stacks at all -- the same limit the allocation sites have below.

## Where the allocations come from: `SPINEL_ALLOC_REPORT`

```
SPINEL_ALLOC_REPORT=1 ./app            # to stderr
SPINEL_ALLOC_REPORT=alloc.folded ./app # to a file
```

At exit the program dumps one line per allocated type, in the folded-stack
format flamegraph tools read, plus `# bytes` companion lines:

```
alloc;String 1100
alloc;Widget 1000
alloc;Hash(String) 1
alloc;(no-scan) 100
# bytes String 24200
```

`(no-scan)` covers objects with no pointers to trace -- an Integer array, a byte
buffer -- which the collector never has to walk.

Counters key on the object's GC scan callback, which is the de-facto type
identity, and are bumped inside the allocator itself. Strings have no scan
callback, so they carry a reserved key of their own and otherwise behave like
any other row -- including on the per-site path below, which matters because
strings are usually the largest share of the bytes. Nothing is sampled, so
two runs of the same program report the same numbers.

### Per-site attribution: `SPINEL_ALLOC_SITES`

```
SPINEL_ALLOC_REPORT=1 SPINEL_ALLOC_SITES=1 ./app
```

Adds the calling frame as an outer folded frame, so a type allocated from three
places appears three times:

```
alloc;./app(+0x2bc5) [0x5a0a1e7acbc5];(no-scan) 5
```

The site is captured as a return address on the counted path and symbolised
only at exit, so the extra cost is one stack walk per allocation and no
allocation of its own. Names resolve as far as the dynamic symbol table
reaches; a `static` method -- which is how user methods compile -- shows as an
address. Turn it into a name with the symbol map from `--profile`, or with
`addr2line -f -e ./app <addr>` on a build that kept its symbols.

Two caveats:

- The walk needs unwind information. A build that discards it (for instance
  linking with `--gc-sections` on a stripped binary) reports sites as absent
  and falls back to the per-type lines.
- One frame is not always the frame you want: an allocation inside an inlined
  helper is attributed to whatever the compiler left as the caller. Read the
  addresses as "the code that asked for this", not as an exact source line.

A program with more distinct *(type, site)* pairs than the stats table holds
does not silently fold them together. What did not fit is reported on its own:

```
alloc;(unattributed) 3
# bytes (unattributed) 78
# note the stats table (8192 entries) was full: 3 allocation(s) could not be
# attributed and are NOT counted in the rows above
```

Every row above that line is still exact -- the overflow is kept out of them
rather than added to whichever row the probe happened to land on.

### While it is still running: a signal

`atexit` is a mode a server cannot use: it is stopped by a signal, so the
counters it spent the whole run filling are lost at the moment they are worth
reading. `SIGUSR1` asks for a dump in flight, and the program carries on:

```
SPINEL_ALLOC_REPORT=alloc.folded ./server &
kill -USR1 $!          # writes alloc.folded now
```

Each dump rewrites the whole cumulative table, so a WINDOW is two dumps
subtracted -- which is also how a server's boot is kept out of the profile:

```
kill -USR1 $pid; sleep 1; cp alloc.folded before.folded
#   ... run the work you want to measure ...
kill -USR1 $pid; sleep 1; cp alloc.folded after.folded
awk 'NR==FNR{a[$1]=$2; next} /^alloc;/{print $1, $2-a[$1]}' before.folded after.folded
```

The `# bytes` lines carry their key in the third field rather than the first.

`SPINEL_ALLOC_REPORT_SIGNAL` moves the signal, by number or by name
(`USR1`, `USR2`, `URG`, `IO`, `WINCH`). Three things worth knowing:

- The handler is installed only while the report is on, but while it is on it
  replaces whatever the program had for that signal. A `Signal.trap("USR1")`
  in the program runs later and replaces it back, at which point the dump
  stops arriving -- move the signal rather than fight over one.
- A threaded program parks a thread on the signal, so the dump arrives whether
  or not anything is allocating. A single-threaded one has no such thread: the
  handler sets a flag and the next allocation writes the report, so an idle
  single-threaded program dumps when it next allocates.
- A process that forked after startup has the handler in the child but not the
  thread; the child falls back to the flag. Signal the parent.

## Which one to reach for

Start with `--profile` and a sampler: it tells you which method to look at.
Reach for `SPINEL_ALLOC_REPORT` when the profile points at the collector
(`sp_gc_collect`, `sp_gc_mark_all`) or at `malloc` -- then the question is not
which code is slow but which code allocates, and the counters answer that
exactly rather than statistically.

## Compiler phase timing

`--timing` (or `SP_TIMING=1` in the environment) makes the compiler report how
long its own phases took. It is about the compiler, not the compiled program
(`--profile` above is the program's). The compiled output is the same with
and without it; with it off nothing is measured.

Each phase is one line on stderr, `key=value` fields after the name:

```
spinel-timing: phase=frontend ms=4.4
spinel-timing: phase=analysis_fixpoint ms=3.2 rounds=4
```

`ms` is wall time on a monotonic clock. Phases, in the order they finish:

| phase | covers |
|---|---|
| `frontend` | parse, require resolution, loading the AST |
| `an_desugar_register`, `an_class_structure`, `an_block_inline`, `an_pre_fixpoint` | the analysis phases ahead of the fixpoint |
| `analysis_fixpoint` | the inference fixpoint (`rounds=N`, plus `capped=1` if it hit the cap) |
| `analysis_renarrow` | the loop that re-narrows poly slots once the fixpoint has settled (`rounds=N`); inside `analysis_fixpoint` |
| `an_post_fixpoint`, `an_procs`, `an_method_backstops`, `an_late_widen`, `an_proc_returns`, `an_storage`, `an_value_types`, `an_reconcile_check` | the analysis phases after it |
| `analysis` | all of `analyze_program`; includes the phases above |
| `codegen_program` | analysis and C generation; includes `analysis` |
| `write_c` | writing the C file |
| `cc_preprocess`, `cc_split` | a split build (`--jobs=N`, or a large unit): the preprocess and the split into parts |
| `cc_compile` | a split build: the wall span of the parallel object compiles (`jobs=N`), not the sum of the workers |
| `cc_link` | a split build: the link |
| `cc_total` | the whole native step, single unit or split |

A phase nested in another is counted in both, so the lines do not add up to the
total.

Each pass of the inference fixpoint also gets a line, its wall time summed over
the rounds, longest first, right after `analysis_fixpoint`:

```
spinel-timing: pass=infer_write_types ms=47.2 calls=15 changed=12
```

`calls` is how often it ran, `changed` how many of those calls reported a
change to the fixpoint (a pass the fixpoint calls only for its effect counts
none). The name is the C function's. The passes are a part of
`analysis_fixpoint` (and of `analysis_renarrow` for the ones its loop runs);
the remainder is the fixpoint's own bookkeeping. With the flag off a pass call
costs a flag test. A phase that did not run (a `-c` build has no `cc_*`) or failed prints
nothing, so a failed build is not a sample. Record the compiler, the input,
the flags, the host and the cache state beside the lines; they are not in them.

## Source positions of a generated .rb

A Ruby file that a tool generated (a template compiler, a transpiler) can say
where its lines came from. A whole line

```ruby
#<SPINEL_SOURCE>greeting.html.erb:12
```

makes the lines after it report as `greeting.html.erb`, line 12, in `#line`
directives, `-g` / `--debug` stepping, `perf` / `addr2line`, `--warn-widen` and
`--check-stores`. The position is held (every following line reports line 12,
not 13, 14, ...) until the next marker or the end of the file it is in. The
text after `>` splits at its last colon, so the path may hold one; a line with
no `:<positive number>` is an ordinary comment. CRuby treats the marker as a
comment too.

Only the reported position moves. `__FILE__`, `__dir__`, `__LINE__` and
`require_relative` still answer from the `.rb` the code is in, and a syntax
error is reported at the generated file.

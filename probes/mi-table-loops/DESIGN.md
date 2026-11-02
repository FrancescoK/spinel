# Table loops as a loop form of the walk

Part of #9898. A class or module body's loop over a constant Hash that names
constants and classes with `const_set` runs as a form of the walk, answering
its preconditions from the load record at its point, instead of as a
pre-walk desugar answering them with whole-program scans.

- Probe table: `TABLE.md`; `./run.sh <spinel>` re-runs it (11 probes; e9
  requires a file under `e9_in_required_file_lib/`).
- **Status of this document.** Unlike the other parts of the split, no full
  design pass was written for this step. This page states what master does
  (read at `94288ce9b`), the facts the load-model plans state about it, and a
  probe set written for it. The mechanism below is the shape those facts
  imply, not a reviewed design.

## 1. Today

### 1.1 Two implementations

- **Inline** (`--load-model=inline`, the default): `sp_const_loop.c` (707
  lines) expands the loops as text before the parse.
- **Graph**: `desugar_table_loops` (analyze_ct.c) runs among the lowerings in
  `an_phase_desugar_register`, before qualify and before the walk, on graph
  tables only (`ct_loops_in_analysis`; `SPINEL_TABLE_LOOPS=analysis` turns it
  on under inline for comparison). It runs the loop in the compile-time
  evaluator (ct_eval.c) and writes its effects as the body's own statements
  in place of the loop: `RC_OK = 200; class OK < Success; @code = 200; end;
  CodeToError[200] = OK; ...`. The classes it names are ordinary class
  nodes, which qualify and registration then treat as written classes.

### 1.2 The shape

A statement of a class or module body, `H.each` or `H.each_pair` with a
block of two parameters, H a constant the body assigned a Hash literal of
literal keys and values earlier. A class it makes must be named by a
`const_set` before anything else uses it, and gets instance variables only
before then. Strings are written as literals; an object the loop made is
written at one place only.

### 1.3 The four questions, each a whole-program scan

| question | function | what it asks today |
|---|---|---|
| the table is only read | `ct_table_only_read` | the table's constant is written once and named elsewhere only as the receiver of a call that leaves it as it is |
| no other value for the constants it sets | `ct_const_given_elsewhere` | none of the constants the loop sets is written, opened as a class, or `const_set` anywhere else in the program |
| no core method it ran is changed | `ct_core_method_changed` | the program changes none of the core methods the loop ran (`Symbol#upcase`, `String#gsub`, ...): a def, alias, mixin, `class_eval` or refinement anywhere in the class or its ancestors |
| no hook or override the effects would run | `ct_method_defined` | the program defines no method named `inherited` (a loop that makes classes), `const_set` / `const_added` (a loop that sets constants), `instance_variable_set` (one that sets ivars), on any receiver, anywhere |

Because each question looks at the whole program, a definition **after** the
loop declines it, although CRuby has run the loop by then (probes e5, e6,
e7: refused in both models; CRuby answers).

### 1.4 Probe table at `94288ce9b`

| probe | CRuby | inline | graph |
|---|---|---|---|
| e1 values (`const_set("K_#{k.upcase}", v)`) | `1 2` | refused | ok |
| e2 values whose leaf another module also writes | `1 2 9` | refused | ok |
| e3 classes (`Class.new(Base)` named by `const_set`, `each_pair`) | `1 "Codes::Two" Codes::Base` | ok | ok |
| e4 a made class whose leaf is also a top-level class | `Codes::Base :top` | refused | ok |
| e5 `inherited` defined after the loop | `inherited Codes::Base` | refused | **refused** |
| e6 `Symbol#upcase` redefined after the loop | `1 :changed` | refused | **refused** |
| e7 another class defines its own `const_set` | `1 :mine` | refused | **refused** |
| e8 a method reading a made constant | `1` | refused | ok |
| e9 the loop in a required file | `3` | refused | ok |
| t_class_table_loop_values, t_class_table_loop_status_classes (corpus tests) | see TABLE.md | ok | ok |

Inline refuses most value loops that graph handles; that difference goes
when graph becomes the default. The three graph refusals are the scans.

## 2. The facts the plans state

- **The form.** Table loops become a loop form of the walk, and
  `ct_core_method_changed` becomes `elab_method_at` per method the loop ran,
  asked at the loop's point. Estimated ~200 lines (net −50). Prerequisite:
  the walk-side host (`host_splice` with spliced statements walked next),
  which is on master and which the class-body macro form already uses.
- **Constant writes need constants keyed from the record.** A write the walk
  makes is seen neither by `qualify_colliding_consts` (before the walk) nor
  consistently by registration, so e2's `Tbl::K_A` beside `Other::K_A` would
  merge. The first PR of the constant-keys work (the fork branch
  `mi-const-keys`) keys walk-made writes with all others. That PR is the
  prerequisite for the values.
- **Classes the loop makes need more.** A class made during the walk must
  register as its own class, but registration today is by qualify's
  spelling, and a later `class One` elsewhere that qualify did not see collide
  with it would merge with it (e4). That is the class half of retiring
  qualify (the `comp_class_index(name)` readers onto the node -> class map),
  which is not startable yet.
- **When the inline model goes**, `sp_const_loop.c` (707 lines) goes with it,
  and so do the scans of 1.3.

## 3. Proposed shape

- **Values now, classes later.** The walk form takes loops whose effects
  are constant writes of values (and Hash stores); a loop that makes a class
  stays on today's pre-walk desugar, unchanged, until the class half lands.
  That keeps e3, e4 and the two corpus tests on the path that answers them
  today: no program goes from right to refused.
- **The questions at the loop's point**, for the loops the form takes:
  - core methods it ran: `elab_method_at(core class, meth, p)` per method,
    so a redefinition after the loop does not count (e6);
  - `const_set` / `const_added` / `instance_variable_set`: the method a call
    on the frame class reaches at p (`elab_method_at` on its singleton
    chain), so another class's override does not count (e7);
  - the table only read: the table constant's history in the record (one
    write, before p) plus the existing check of its readers;
  - other values for the constants it sets: the constant entities' histories
    after keys come from the record, instead of a scan by spelling.
- **Effects** come back from the evaluator as data (`CtFx`) and become
  statements through `host_splice` at the loop, which the walk records next;
  the loop is consumed. Constant writes are keyed after the walk with all the
  others.
- **Inline** stays byte-identical by construction: the form runs only under
  graph (and under `SPINEL_TABLE_LOOPS=analysis`), as the macro form does.

Expected answer changes: e6 and e7 refused -> right under graph. e5 (a loop
that makes classes, with `inherited` defined after it) stays refused until
the class half, then becomes right with `inherited` asked at p (with
#10770's firing, CRuby calls it while the class has no name).

## 4. PR and checks

One PR after the constant-keys work's first PR, ~200 lines (net −50 once the
scans for value loops go). Checks: cident 0 (inline unchanged); a graph run
over the suite with no pass turning into a failure; the probe table, none
worse; new tests (a value loop with a core method redefined after it; one
with another class's `const_set` override) under graph, promote and GC
stress; scale: a generated program with N modules each running a table loop
over a K-entry Hash, linear in N × K, no whole-program rebuild per splice.

## 5. Not covered

- An Array loop calling `const_set` in a class body (`%i[A B].each { |n|
  const_set(n, ...) }`): neither a table loop nor a macro; refused in both
  models.
- Loops that make classes, until the class half (above).

## 6. Open questions (with our recommendation)

1. **Classes the loop makes before the class half.** Options: (a) keep such
   loops on today's pre-walk desugar until then (recommended: no answer
   changes, the scans stay only for them); (b) the walk form declines a loop
   when a class it makes has a leaf the record shows written by another
   entity anywhere (0 corpus table loops collide, but e4 goes right ->
   refused under graph).
2. **One PR or two** (questions at p first, then the form). Recommended: one;
   the questions at p only make sense once the loop runs at p.

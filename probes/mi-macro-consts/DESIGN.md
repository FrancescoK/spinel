# Class-body macros that write constants, under the load graph

Part of #9898. The constant half of class-body macros: a macro called in a
class body whose body runs `const_set` (and keeps per-class state that a
later macro reads to build a name) runs as a walk form under
`--load-model=graph`, as the define_method / attr / text macros already do.

- Probe table: `TABLE.md`; `./run.sh <spinel>` re-runs it.
- Depends on the constant-keys work (the fork branch `mi-const-keys`):
  its first PR, which names constants from the load record after the walk.

## 1. Where it stands

The class-body macro form is on master (#10669, #10674, #10686, #10692,
#10695, #10713): a class-body call statement whose target the record finds
(`elab_method_at`, singleton chain, at the call's point) is a program def
runs in the compile-time evaluator's macro mode with self set to the frame
class; its effects come back as data (`CtFx`) and become code through
`host_splice`, which the walk then registers. It covers define_method,
attrs, nested macros, residual statements and computed `module_eval` text.

It declines two kinds of program, which then stay refused under graph
(inline still expands them through the parse-layer text pass, sp_macro.c):

- a macro effect that is a `const_set` (`CT_FX_CONST_SET`);
- a macro that reads per-class state another macro call wrote earlier
  (`kind :box` then `constant :SIZE`, whose name is built from `kind`).

At `94288ce9b` all 13 probes pass inline and are refused under graph:

| probe | graph today |
|---|---|
| t_class_body_macro_state, _long_elsif, _reverse, _scoped_alias, _builtin_literal, _expansion (corpus tests) | `unsupported send with a runtime method name` (the `public_send` that builds the name from state) |
| t_macro_inspect_runtime (corpus test) | `unsupported call ... const_set` |
| m1 (one `const_set` macro), m3 (two classes' `SIZE` plus a top-level one), m4 (a read before the macro's point), m6 (`const_set(c, text.inspect)`) | `unsupported call ... const_set` |
| m2 (state then constant), m5 (state set in both arms of an `if`) | `unsupported send with a runtime method name` |

The `t_*` programs are copies of the corpus tests with those names; they are
7 of the programs that keep the graph model from being the default.

## 2. Why it waits for constant naming

Constants are named by string before the walk today
(`qualify_colliding_consts`), and registered by node name after it
(`register_globals_consts`). A `const_set` the walk runs is seen by neither:
it gets no slot, and its reads cannot be renamed consistently. `Calc::SIZE`
and `Small::SIZE` in class_body_macro_state are the case: two macro-made
writes of one leaf need `Calc__SIZE` / `Small__SIZE`, the keys qualify gives
the text expansion's output under inline. Once constants are keyed from the
record after the walk, a walk-made write is keyed and registered with every
other write. Rejected alternatives: qualifying form-made writes one by one
and renaming the reads the record resolves to them (a second naming path),
and declining on any collision (leaves 4 of the 7 corpus programs refused).

## 3. The mechanism

### 3.1 S5: `const_set(name, value)` becomes a constant write

- The evaluator already returns `CT_FX_CONST_SET` with the name and value.
- The form splices `NAME = value` (or `M::NAME = value` when the frame is
  reached by path) at the call through `host_splice`. The walk reaches it next
  and records it (`lr_const_write`), so it is in its history and in the
  record's write map like any written constant.
- Naming runs after the walk, so the write is keyed with all the others.
- Its reads resolve through the record: a method-body read (`def self.info =
  [SIZE, ...]`) as of the load's end; `Small::SIZE` through the parent; a
  class-body read before the macro's point is NO, so `defined?(SIZE)` there is
  false (probe m4: CRuby `:none`, then 32).
- The value is written as a literal the evaluator can spell; a String whose
  text needs escapes the evaluator does not spell as CRuby does (`"\e"`, `#`,
  an operator Symbol) keeps its `inspect` for run time, as sp_macro.c does
  (macro_inspect_runtime, probe m6).

### 3.2 Per-class state followed across the walk's statements

- The evaluator follows per-class instance-variable state (`@kind`) over the
  class body's statements as the walk reaches them, for each class
  separately and across reopened bodies (class_body_macro_state's `Small`).
- A branch the walk records as `may` merges its states: arms that agree
  leave the state known (probe m5, `Agree`); arms that disagree make it
  unknown, and a later macro that reads it declines.
- A state-only macro (`kind :box`) stays a run-time call, so its effect still
  happens when the program runs (`Calc.kind` answers `:box`); its state is
  followed for the later macros.
- Calls from a method (a run-time `kind` with no argument) are reads, not writes.

### 3.3 Declines (unchanged rules, plus one)

Everything the form declines today still declines (opaque history, non-public
body visibility, builtin frames, an unstable macro def, a user-defined hook or
reflective primitive the body reaches, captured values that are not literals,
a guard conflict). New: a state read whose merged value is unknown.

## 4. Inline byte-identity

The form runs only under the graph model (and under the test switch
`SPINEL_CLASS_MACROS=analysis`, which turns sp_macro off under inline). Under
inline, sp_macro has already expanded every macro, so the form finds nothing:
inline C is unchanged by construction. The A/B switch runs the test suite
and the macro programs in test/reject with sp_macro off and the form on, and
lists every program where the two differ.

## 5. PR and checks

One PR, ~350 lines (S5, the state follower with the branch merge, state-only
macros kept as calls), after the constant-keys PR.

- All 7 corpus programs pass under graph; the macro programs in test/reject
  (62 when counted at `b74120805`) each stay refused or print CRuby's output
  under graph.
- cident 0 (inline unchanged); a graph run over the suite with no pass
  turning into a failure; the A/B switch list.
- New tests, each under graph, `--int-overflow=promote` and
  `SPINEL_GC_STRESS=1`: a state macro under an `if` (merged state);
  colliding macro constants in two classes; a constant read before the
  macro's point (CRuby's answer).
- Scale: the existing `test/scale/class_macros.sh` / `class_macros_one.sh`
  plus a shape with one class and K state-following calls, at K = 200 / 400: no whole-program
  rebuild per splice (parent map, kind lists, `elab_fresh`), linear work.

## 6. Not covered

- `pkg.ffi.ffi_class_body_macro` is still refused under graph
  (`module_eval` with 3 arguments). It is not a constant: the form declines
  because the class body first calls `ffi_lib`, a program method from
  packages/ffi that writes the class's instance variables, which the
  precondition treats as opaque. Without the `ffi_lib` line the macro expands
  under graph. It needs a narrower opacity rule in the form's precondition
  (a library class method the record follows and that writes only state the
  macro does not read), a separate change.
- An Array loop calling `const_set` with computed names in a class body
  (`%i[A B].each { |n| const_set(n, ...) }`) is refused in both models: it is
  neither a macro nor a Hash table loop.
- Macros inside `Class.new` / `Struct.new` blocks, in builtin class reopens,
  and under non-public body visibility keep declining.

## 7. Open questions (with our recommendation)

1. **One PR for S5 and the state follower.** Recommended: yes. Six of the
   seven corpus programs need both (the state builds the constant's name), and
   the state follower alone fixes nothing.
2. **State-only macros stay run-time calls.** Recommended: yes. Their effect
   (the ivar) is observable at run time (`Calc.kind`), and keeping the call is
   what the text expansion does.
3. **Disagreeing branch states decline rather than refuse the program.**
   Recommended: decline (the call stays as written and is refused as today),
   so no program gets worse.

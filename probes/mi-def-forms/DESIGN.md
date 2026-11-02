# Definition forms recorded by the walk: singleton attrs, undef forms, eval frames, frame facts

Part of #9898. Three independent steps, each deleting a pre-walk rewrite
whose fact the load record holds (or can hold) at the form's point:

1. `singleton_class.attr_*` and the literal `undef_method` forms record at their point;
2. the eval frames (`instance_eval` defs, a class body's `module_eval`, a top-level static `class_eval`) are frames the walk opens;
3. the frame facts (`self.v = x` / `v` in a class body, a bare `tap { }` in a class body) are reads of the frame's self.

- Probe table: `TABLE.md`; `./run.sh <spinel>` re-runs it (26 probes).
- File names and functions below were re-read at `94288ce9b`; the inventory was first taken at `6c330151b`, and every probe answers the same at both.

## 1. Today

All these passes run in `an_phase_desugar_register` before `elab_program`
(except the fixpoint duplicate, which runs after it), and each rewrites the
tree so that later passes see a plainer shape.

| form | pass | shape it leaves | what the record holds at the form's point |
|---|---|---|---|
| `singleton_class.attr_reader :x` (and writer / accessor, `self.singleton_class...`) | `desugar_singleton_attr` (analyze_desugar.c) | `def self.x` / `def self.x=` | nothing: the attr call is not recorded. b03, b04, b26 are C compile errors (an undeclared `sp_Foo_s_x`; an `sp_oint` passed as `sp_int`) |
| `undef_method :a, "b"` with literal names | the lowering row `LW_LITERAL_UNDEF_METHOD` (`desugar_literal_undef_method_at`) | `undef a` | an undef entry after the row (`lr_alias_undef`); `register_undefs` (analyze_scope.c) then reads the tree, not the record, so it applies an undef regardless of its point (b21, b22) |
| `K.instance_eval { def m }` | `desugar_instance_eval_defs` | `K.class_eval { def K.m }` | an instance_eval frame (`LR_FS_IEVAL`) |
| `self.module_eval do S end` in a class body | `desugar_body_module_eval` | S spliced into the body | the self-class_eval frame at p |
| top-level `K.class_eval { ... }` | `desugar_static_class_eval` (a host step) | the statements in a reopening of K | the frame, from the class-builder frame writer (#10717, #10737) |
| `self.v = x` / `v` in a class body | `desugar_class_body_self_calls`, duplicated by `desugar_body_self_call` in the post-walk fixpoint | `Cls.v = x` / `Cls.v` | the frame's self at p; no form |
| `tap { }`, `name`, `frozen?` as a class-body statement | `desugar_class_body_object_acts` | `self.tap { }` | the frame's self at p; no form |

## 2. End state per form

- **Singleton attrs.** The walk records an attr entry on the singleton at p
  (the attr kind of `lr_method`), with its reader / writer names; codegen
  makes the accessors as it makes a `class << self; attr_reader :x; end`
  (b28, which works today). `desugar_singleton_attr` goes.
- **Literal undef_method.** Recorded through `lr_alias_undef` with the
  literal names at p. The row goes, and `register_undefs` reads the record's
  undef entries, each at its point, so a method defined after the undef is
  defined (b21, b22).
- **Eval frames.** instance_eval blocks, a body's `module_eval` / `class_eval`
  on self, and a top-level `K.class_eval` block are frames the walk opens at
  p; defs inside record into the frame's owner. No tree rewrite.
- **Frame facts.** `class_body_self_calls`, its duplicate `body_self_call` and
  `class_body_object_acts` become reads of the frame's self at p (and the
  frame's default visibility for statements spliced into it); nothing is
  rewritten, and the duplicate pass in the fixpoint goes.

Layers: facts in the load record (analyze_elab.c writers); targets and
refusals in the call plan; no new globals or tables; names through
builtin_names.c predicates.

## 3. Answer changes and byte-identity

| step | C | probes |
|---|---|---|
| 1 attrs / undef | changes for the C-error programs and the undef order | b03, b04, b26 C error -> right; b21, b22 wrong -> right. b01 / b02 keep their one wrong line each, `Foo.method(:m).owner == Foo.singleton_class` (false; CRuby true): the attr values are right, the owner rows are reflection, not covered |
| 2 eval frames | byte-identical on the corpus expected | none of the probes changes: a24 (instance_eval def on a plain Object) stays a compile error, a26 / a26b (class_eval on a run-time class value) stay refused, a29 (`class_exec` with a Method block) stays wrong. m15 (a def in a top-level `K.class_eval` block firing `method_added`) becomes right together with #10771 once the block is a frame |
| 3 frame facts | byte-identical expected | none; a30's `instance_methods(false)` before the def is reflection at a point, after the default-model switch |

No step moves a probe from right to wrong, right to refused, refused to
wrong, or wrong to differently wrong.

## 4. PR split

| PR | contents | size (est.) | depends on | scale program |
|---|---|---|---|---|
| 1 | singleton attrs record at p; the literal undef row goes; `register_undefs` from the record | +90 / −110 | none; touches the records #10771 (singleton_method_added for attrs) and #10772 (method_undefined) fire from, so it rebases onto them if they land first | N classes each with a `singleton_class.attr_accessor` and an `undef_method`: linear |
| 2 | instance_eval defs, body module_eval, static class_eval as frames | +100 / −430 | the class-builder frame writer (merged: #10717, #10728, #10731, #10736, #10737) | N classes each with a top-level `K.class_eval` block and an `instance_eval` def: linear |
| 3 | class-body self calls (and the fixpoint duplicate), class-body object acts, frame visibility | +100 / −150 | the same frames | none needed (linear in body size) |

Each PR: cident with its list explained; the probe table under both models,
none worse; new tests plain, under `--int-overflow=promote` and under
`SPINEL_GC_STRESS=1`; scale-test.

## 5. Not covered (master has the same)

- b01 / b02 owner rows (`Method#owner` of a singleton attr).
- a24: a method defined in an instance_eval block on a plain object (a
  singleton class of a non-class object).
- a26 / a26b: `class_eval` on a run-time class value held in a local.
- a29: `class_exec` / `instance_exec` with a `Method` as the block.
- a30: reflection (`instance_methods(false)`) answered at a point.

## 6. Open questions (with our recommendation)

1. **Three PRs, in the order 1, 2, 3.** Recommended: yes. They share no code;
   1 has the answer changes, 2 and 3 are deletions.
2. **`register_undefs` reads the record in PR 1, not the tree.** Recommended:
   yes; it is what makes b21 / b22 right, and the row's rewrite then has no
   reader left.
3. **m15 counted with #10771.** Recommended: list it in PR 2 only if #10771
   has landed; otherwise PR 2 states it as the expected follow-on.

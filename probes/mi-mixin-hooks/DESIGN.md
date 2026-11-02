# `included`, `extended` and `prepended` fire at the walk's mixin events

Part of #9898. The mixin half of hooks firing per point: the hook a mixin
fires is the one live on the module at the mixin's point, found by the load
record, not the first `def self.included` found in any body.

- Probe table: `TABLE.md`; `./run.sh <spinel>` re-runs it (30 probes; n16
  requires a file under `n16_lib/`).
- Builds on #10770, #10771 and #10772 (open), which fire `inherited`, the
  `method_added` family and `method_undefined` at the walk's events. Their
  machinery is what this extends: `elab_fire_after` (hooks for the events a
  statement recorded, spliced after it through the walk's host),
  `lr_hook_live` (is the hook live on the class's singleton at p, through
  `elab_method_at`), `lr_hook_call` (`recv.__send__(:hook, arg)` or a bare
  `hook(arg)`), and no-op rows for a hook name with no program target.
- Facts re-read at `94288ce9b` (the design was written at `6c330151b`; every
  probe answers the same at both).

## 1. Today

`desugar_included_hooks` (analyze_desugar.c, a host step before the walk,
~520 lines with its helpers `incl_find_hook_named`, `incl_subst`,
`incl_emit_stmt`, `incl_hook_returns`, `incl_hook_call`, `incl_find_hook_at`,
`incl_names_build`):

- for a receiverless `include` / `extend` with a constant argument, in a
  class body or Struct block (a module body skips `include`);
- the hook is the module's first `def self.included(one_param)` /
  `def self.extended` **in any of its bodies**, found through qualified names;
- the body is cloned with `base` substituted and spliced after the include;
  a body with its own `return` becomes `M.__send__(:included, self)`.
- `prepended` is never fired; a module including a module, a top-level
  `K.include(M)` and a hook reached through `extend` are skipped.

So a hook defined after the include, redefined, or removed between two
includes answers wrong (the first def found fires at every include), and the
skipped events fire nothing.

Corpus (test/ and packages' tests): `included` in 28 programs, `extended` in
9, `prepended` in none. A Prism scan of the 43 included / extended /
prepended bodies: 13 with `class_eval`, 12 plain, 3
mixins, 3 `return`, 2 `class_eval` + mixin, 2 `class_eval` + def, 2 ivar, and
one each of ivar call, `super`, `class_eval` + def + ivar, `class_eval` +
define_method, `class_eval` + define_method + return, `class_eval` + ivar.

## 2. Mechanism

### 2.1 The event

A mixin the walk records (`include`, `extend`, `prepend`, receiverless or on
an explicit receiver, in a class, module or builder block) is an event. At
it, `lr_hook_live(module, hook, p)` decides: YES with a program version
fires; NO fires nothing (the core hooks are no-ops); UNKNOWN (a `may`
version, an unplaced region under graph) fires, as master does, and the call
binds as master binds it.

### 2.2 Spliced vs called

- **Spliced**, only where master splices today: the live version is a
  `def self.<hook>(one_param)` written in the module's own body; the event is
  a receiverless mixin in the includer's body (class, module or builder
  block); the body has no `return` of its own and no `super`; and it is not
  the lone-conditional dispatcher of conditional defs. The clone is master's
  (`incl_subst` / `incl_emit_stmt`), now called by the walk at the event.
- **Called** (`lr_hook_call`) otherwise: a hook reached through `extend` or
  `define_singleton_method`; a top-level `K.include(M)`, whose frame is not
  the includer's body; a body with `super` (CRuby gives nil through
  `Module#included`); the conditional dispatcher. A called hook whose body
  defines on its base at run time stays refused where master refuses it.

### 2.3 The precondition for spliced bodies

A body spliced at the walk misses every pre-walk step between the hook stage
and the walk. The steps that read a shape a hook body can carry, and what
the walk does with such a body:

| shape in the hook body | steps that read it | here |
|---|---|---|
| include / extend / prepend | the explicit-receiver, singleton-class and `extend self` mixin rewrites, `extend_enumerable`, `extended_module_attrs`, the mixin arm of the ivar passes, `self_const_get` (includers), `qc_object_mixin_write` | decline until the mixins step (the fork branch `mi-mixins`) lands; `host_prewalk_shape` already lists mixins |
| `const_get` / `const_defined?` / `self::X` | the const_get desugars | decline (listed) |
| ffi declarations | `ffi_library_functions`, `native_func_defs` | decline (listed) |
| a constant write, including a `const_set` the rows lower to one | `constant_path_self_alias`, `qualify_colliding_consts` | decline until constants are keyed from the record (the fork branch `mi-const-keys`). Reads are safe: the clone comes from the hook's def, which qualify already renamed |
| alias / alias_method | the alias passes | decline (listed) |
| a class-body-level ivar after the unwrap, `instance_variable_get` / `_set` | `body_ivars`, `class_eval_ivars`, `const_ivar_access` | decline (**new** in the predicate) |
| a bare Object / Module method as a body statement (`tap`, `name`, `frozen?`) | `class_body_object_acts` | decline (**new**, that step's own predicate) |
| the includer is a core class (or Thread / Fiber) | the builtin-reopen passes, `handle_attr_accessor`, `fiber_prepended_init`, `handle_ivars` | decline when the includer is a core class (**new**) |
| `singleton_class.attr_*`, `class << x`, `attr_*(*C)`, a `module_eval` left after the unwrap, `class_eval(&o.method)` | `singleton_attr`, `sclass_readers_through_class`, `attr_const_splat`, `body_module_eval`, `eval_method_block` | decline (**new**) |
| `v op= x` where the program reopens that operator | `reopened_op_write` | decline under that step's own predicate |
| a require | the load-order steps | decline |

One predicate: `host_prewalk_shape` widened by the new rows, each using the
step's existing predicate, with a comment naming the step. A hook is declined
per (module, hook name) when any of its versions is declined; its includes
then keep master's pre-walk splice, and the walk skips them, so nothing fires
twice. The residue is the old pass restricted to declined hooks.

### 2.4 Layers

| fact | layer |
|---|---|
| is the hook live at p, which version | the load record (`elab_method_at`) |
| event -> hook names | `implied_calls.inc`, `definition_form_hooks` / `is_definition_hook_name` (builtin_names.c) |
| which version a fired call runs | the call plan (`call_target` at p) |
| a hook with no program target answers nil | builtin-op rows |
| splice vs call, the decline set | the walk form, through the predicate beside `host_prewalk_shape` |

### 2.5 Cost

Hooks fire where CRuby fires them: C is unchanged for a program whose hook is
defined before all its events. Code is removed where master fired too early
or fired a removed hook; calls are added only at events master never fired
(`prepended`, module-in-module includes, `K.include(M)`, hooks through
`extend`). Compile time: one `lr_defines` lookup per event per hook name;
`elab_method_at` only when the program defines that hook. The whole-table
scans (`incl_names_build`'s parent map and qualified names, the pass's class
loop) go with the residue. The existing many-splices scale program
(`test/scale/splices.sh`) covers the first PR.

## 3. Answer changes (CRuby / master / after)

Inline and graph answer alike for every probe here.

| probe | CRuby | master | after | PR |
|---|---|---|---|---|
| n02 hook added after the first include | `inc B` | `inc A` `inc B` | CRuby | 1 |
| n03 hook redefined between includes | `v1 A` `v2 B` | `v1 A` `v1 B` | CRuby | 1 |
| n04 hook removed between includes | `inc A` | `inc A` `inc B` | CRuby | 1 |
| n05 `extended` added after the first extend | `ext B` | `ext A` `ext B` | CRuby | 1 |
| n16 hook defined in a required file after the first include | `inc B` | `inc A` `inc B` | CRuby | 1 |
| n23 hook redefined in the module's body between two includes of it | `v1 A` `v2 M::Inner` | `v1 A` `v1 M::Inner` | CRuby | 1 |
| n27 hook defined after the first include, in a reopening of the module inside the includer's body | `inc A` | `inc A` `inc A` | CRuby | 1 |
| n06 `prepended` | `pre A` `pre N C` | nothing | CRuby | 1 |
| n13 a module including a module | `inc M2` | nothing | CRuby | 1 |
| n14 `K.include(M)` at the top level | `inc K` | nothing | CRuby (called) | 1 |
| n15 the hook comes from a module M extends, added after the first include | `hooked B` | nothing | CRuby (called) | 1 |
| n08 `super` in `included` | `inc A nil` | refused | CRuby (called; nil from the hook no-op) | 1 |
| n18 `included` defined under a run-time condition that does not hold | `done` | refused | CRuby (called; the dispatcher's undefined arm is nil) | 1 |
| x07 `extend self` fires `extended` | `ext M` `hi` | `hi` | CRuby once the mixins step records `extend self` as an event | after the mixins step |

Unchanged: n01, n07, n09, n11, n12, n20, n21, n22, n24, n25, n26, n28 stay
right (n24, n25, n26, n28 and n09 are the nets: each carries a shape the
predicate declines, so it keeps master's path); n17, n19 and x01 stay refused
(an include in a method, `Object#extend`, an include on a run-time class);
n10 stays wrong (below).

## 4. PR split

| PR | contents | size | depends on | tests |
|---|---|---|---|---|
| 1 | the mixin arm of the walk's events: splice (2.2) or call; the decline predicate beside `host_prewalk_shape`; `incl_subst` / `incl_emit_stmt` called by the walk; the pre-walk pass restricted to declined hooks | ~+130 / −40 | #10770-#10772 | hook_included_per_point (n02-n05, n23, n27), hook_mixin_events (n06, n13, n14, n15), hook_included_called (n08, n18), a `test/load_graph` pair for n16; each under promote and GC stress |
| 2 | the residue and its scans go (`incl_find_hook_*`, `incl_names_build`, `incl_qualified`, the pass's class loop) | ~+10 / −260 | PR 1; the mixins step; constants keyed from the record (for `const_set` bodies); the ivar / object-act steps becoming walk-capable | the five nets move to the walk path unchanged |

Checks per PR: cident with each changed program explained (a new fire, a
removed early fire, or none); the probe table under both models, none worse.

## 5. Not covered (master has the same)

- n10: `b.const_set(:FROM_M, 1)` in an `included` hook. CRuby prints 1;
  master compiles and raises NameError at run time. A wrong answer about the
  spliced `const_set`, not about firing; it stays on the pre-walk path (a
  constant write, declined) until constants are keyed from the record.
- n17, n19, x01: run-time includes and extends stay refused.

## 6. Open questions (with our recommendation)

1. **The events master never fires** (`prepended`, module-in-module includes,
   `K.include(M)`, a hook through `extend`) go in PR 1, each a wrong -> right
   with its probe. Recommended: yes; leaving some out would need a filter
   that exists only to keep master's gaps.
2. **The residue for declined hooks.** Recommended: file PR 1 with the
   pre-walk pass restricted to declined hooks; PR 2 deletes it once the
   mixins step and the constant keys land. The ivar subset (hook bodies with
   class-body ivars or an ivar call: 5 of the 43 corpus bodies) keeps
   master's path, since the ivar passes are representation work outside
   #9898; PR 2 then deletes everything except what those hooks need, and the
   design says so.
3. **UNKNOWN fires**, as master does (no right -> refused for a hook in an
   unplaced file under graph).

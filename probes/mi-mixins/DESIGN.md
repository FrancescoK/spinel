# Mixins recorded by the walk: explicit receivers, singleton classes, `extend self`

Part of #9898. `include`, `extend` and `prepend` on an explicit receiver, on
`singleton_class` or in `class << self`, and `extend self`, record directly
as mixin entries at their point, so the three pre-walk rewrites that give
them a plainer shape go.

- Probe table: `TABLE.md`; `./run.sh <spinel>` re-runs it (18 probes; two of
  them require a file under `<probe>_lib/`).
- Functions re-read at `94288ce9b`; the inventory was first taken at
  `6c330151b`, and every probe answers the same at both.
- Builds on the hook work in #10770, #10771 and #10772 (open).

## 1. Today

| form | pass (analyze_desugar.c) | shape it leaves | what the record holds |
|---|---|---|---|
| `K.prepend(M)` / `K.include(M)` / `K.extend(M)` statement | `desugar_explicit_receiver_mixin` | a synthetic `class K; prepend M; end` | a mixin entry on K at p (`lr_receiver`); but `K.include(Comparable)` inside another body is `include ?` plus `opaque K` (a39). The call plan refuses explicit-receiver mixins it cannot place |
| `singleton_class.prepend(M)`, `class << self; include M` | `desugar_singleton_class_mixin` | `extend M` in the body | a singleton mixin at p, but only through the `sclass_prepend` mark the pass leaves on its `extend` (`lr_mix_kind`) |
| `extend self` | `desugar_extend_self` | a `def self.m` twin per def | **no extend entry**: the twins record as `M.a: def` at each def's point, so `M.a` answers before the `extend self` runs (a08b) |

`elab_class_mixins` (analyze_elab.c) already answers a class's mixins per
point, and `body_mixins` (analyze_scope.c) already reads it.

## 2. End state

- No synthetic reopening, no `extend` rewrite, no def twins. The record's
  mixin entries at p are the only fact, and the readers that still read the
  rewritten tree convert to `elab_class_mixins`.
- The walk itself classifies `singleton_class.prepend(M)` (no mark),
  records `extend self` as an extend of the module on itself at p, and
  resolves a core module named in an explicit-receiver include (a39) instead
  of `?`.
- The call plan's explicit-receiver refusal shrinks to the run-time cases
  (a02: an include inside a block).

Layer: facts in the load record (analyze_elab.c writers); refusals in the
call plan; no new globals or tables.

## 3. Answer changes

| probe | CRuby | master (both models) | after |
|---|---|---|---|
| a05b `singleton_class.prepend(M)` in the body, `hi` before and after | `"K" "M>K" "M>K"` | `"M>K" "M>K" "M>K"` | CRuby |
| a08b `M.a` before and after `extend self` | `:nomethod 1` | `1 1` | CRuby |
| a39 `K.include(Comparable)` inside module N | `:m true` | refused | CRuby |
| a07 `class << self; include M` with `respond_to?` around it | `false false "M"` | refused | CRuby |
| x07 `extend self` fires the module's `extended` | `ext M` `hi` | `hi` | CRuby, together with the mixin-hook firing (the fork branch `mi-mixin-hooks`) |
| a06 `class << self; include M` where M defines `included` | `included in #<Class:K>` `"M"` | refused | CRuby with the `included` firing; see the ordering hazard below |

Unchanged: a01, a04, a08c, a09, a10, a11 stay right; a02 (an include in a
block) and a05 (the singleton ancestry `K.singleton_class.ancestors`) stay
refused; a03 / a03b, a08 and a12 stay wrong (not covered).

**Ordering hazard (a06).** a06 is refused today. With this step alone it
would compile without the hook line: refused -> wrong. Either the
`included` / `extended` / `prepended` firing at the walk's mixin events
(the fork branch `mi-mixin-hooks`, its first PR) lands first, or this PR keeps a
refusal for a singleton-class include of a module whose `included` is
defined. We recommend the first order.

## 4. PR

One PR, about +150 / −700: `desugar_explicit_receiver_mixin`,
`desugar_singleton_class_mixin` and `desugar_extend_self` go; the walk records
`extend self` and core-module includes; consumers read `elab_class_mixins`.
C changes only where the order of mixins differs.

Checks: cident with its list explained; the probe table under both models,
none worse; new tests plain, under `--int-overflow=promote` and
`SPINEL_GC_STRESS=1`; scale-test plus a new generated program (N classes,
each with a `K.include`, a `singleton_class.prepend` and an `extend self` at
the top level), linear.

## 5. Not covered (master has the same)

- a03 / a03b: an include's effect seen through `include?` / `respond_to?`
  before the include runs.
- a08: a call before the def it names (left as is, per #9898).
- a12: `extend Enumerable` seen by a call before it.
- a02 / a05 stay refused (a run-time include; singleton ancestry reflection).

## 6. Open questions (with our recommendation)

1. **Order against the hook firing.** Recommended: #10770-#10772, then the
   first mixin-hook PR, then this one, then the mixin-hook residue PR (which
   needs this one). That avoids a06 going refused -> wrong without a
   temporary refusal.
2. **`extend self` as a mixin event.** Recommended: yes, an extend of the
   module on itself at p, which is CRuby's model; the def twins were a stand-in.

# Where a change goes

Each decision the compiler makes about a program has one home: a layer that
decides it once, in the analysis and representation layer, and that the
emitters read (#7100, #8328). A fix that does not know those homes tends to
land as a special case at one call site: a name test in one emitter, a fact
re-derived where it is needed, a layout read off a type. It answers the
program that found the bug and leaves the next one wrong, and review sends
it back. This page lists the layers, the question each one answers, its
entry points, and how the old way looks in a diff.

Three rules follow from it:

1. **Put a fact in the layer that owns it.** Find the layer in the table
   below before writing code, and make the fix there.
2. **Convert old-style code on the lines you touch.** A line the change
   edits anyway asks the layer, not the old test beside it.
3. **When the right layer lacks the fact, add it there.** Extend the row,
   the plan or the predicate rather than special-casing one call site. A
   fact that needs new analysis is its own change, made first.

## The layers

| A change answers...                                                            | Layer                                              | Entry points                                                                                                                                    | The old way, in a diff                                                                                                               |
| ------------------------------------------------------------------------------ | -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| what a builtin call answers, its arity, its block form, how it is emitted      | builtin-op rows                                    | `builtin_ops.c:bop_find`, `bop_find_arg`, `bop_result_args`; inference `analyze_infer.c:an_bop_find`, `an_bop_result`; emission `codegen_ops.c` | an `sp_streq(name, ...)` arm in inference or an emitter that a row could state; inference computing a result beside the row it found |
| what a builtin does with the Strings it is handed                              | builtin-op share rows                              | `builtin_ops.c:bop_share` (`BSH_*`)                                                                                                             | a name test for a builtin's keep-or-answer contract inside a walk                                                                    |
| which user method a call reaches, its refusal, its poly dispatch, its nil test | the call plan                                      | `call_plan.c:cplan_user`, `cplan_user_in`, `cplan_refuse`, `cplan_poly_arms`, `cplan_targets`, `cplan_nil`; `codegen_util.c:refuse_from_plan`   | method-chain resolution or rebuilt dispatch arms in an emitter; a refusal keyed on a name alone; a nil test written by an emitter    |
| which classes a value can hold                                                 | the class facts                                    | `analyze_cls.c:cls_fact_node`; `compiler.c:comp_poly_candidates_at`                                                                             | every class that defines the method's name taken as a target                                                                         |
| a String's form: the object, its bytes, a new handle                           | the String plan                                    | `share_plan.c:share_plan_of`, `share_plan_producer`; renderer `codegen_str.c:emit_str_form`                                                     | an emitter choosing handle or copy itself; a copy written as literal text; a refusal or copy keyed on one method name                |
| layout in codegen: boxed, scalar, sentinel, handle, struct                     | `Repr` and the type traits                         | `repr.c:repr_of`, `repr_of_slot`; `holder.c:holder_of_node`; `types.h:ty_traits_of`; `codegen_util.c:emit_coerce`                               | layout decided from `comp_ntype`; hand-written boxing or nil tests; a cast into a slot instead of `emit_coerce`                      |
| where a value comes from, how its parent uses it, a Prism flag                 | the value-position walkers and the node predicates | `value_pos.c:for_each_value_position`, `vp_one`, `vp_climb`; `node_table.h:nt_paren_single`, `nt_safe_nav`                                      | recursion over `elsif` or `rescue` with a depth limit; `sp_streq(op, "&.")`; a raw flag bit                                          |
| a fact about one emission, or one poly arm's state                             | views and `ArmCtx`                                 | `codegen_view.c:view_push`, `view_push_repr`, `view_bind`, `view_push_arm`                                                                      | a node's type, flag or name overwritten and restored around an emitter call; a new `g_*` global                                      |
| membership in a family of names                                                | the name predicates                                | `builtin_names.c:is_call_alias`, `is_then_alias`, ...                                                                                           | the same inline `sp_streq` chain in inference and in codegen                                                                         |
| when a pass runs, and what inference reads                                     | the phase driver and the counted setters           | `analyze.c:analyze_program`; `comp_set_ntype`, `lv_set_type`, `ivar_set_type`                                                                   | a loop appended to `analyze_program`; a direct write to a table `infer_type` reads                                                   |

The String plan's row is what is left of the two String representations
(#9258): every String slot is now its handle, the share analysis is gone,
and the String plan and the byte routes are being removed. A change does
not add to them.

Codegen reads decisions, not types. A `comp_ntype` read in an emitter
answers one of two questions, and both have a layer:

- how the value is laid out (boxed, nullable, a handle): `repr_of`;
- what to do with it (this receiver is an Array, so the Array emitter;
  this call reaches that method; this arm is that class): the call plan
  and the builtin-op rows, which hand the emitter the kind, the row and
  the target to switch on.

Reads of the second kind are many today and go as the plan and the rows
take over each emitter. A read stays only where the type is itself the
data, such as a class name in a diagnostic.

## Views

The analysis decides one answer per node: its type, its representation flags,
which method a call reaches. Codegen often emits the same node more than once
under different assumptions: inside each arm of a poly dispatch, where the
receiver is one class; as a temp a receiver was materialized into; with a
flag lifted for one re-entry; as the text of a hoisted argument.

A view says that for one nested emission only. `view_push` (a type),
`view_push_repr` (a representation flag), `view_bind` (the text written for
a node) and `view_push_arm` (a dispatch arm's context) record the previous
answer and install the new one; `view_pop` restores it. Everything that
reads the node in between (`comp_ntype`, `repr_of`, `emit_expr`) sees the
view, and nothing outside it does.

They are one stack rather than ad hoc overrides because each of these went
wrong by hand:

- **An early exit leaves the override behind.** A refusal unwinds every
  view, binding and arm context opened since its `view_mark()`
  (`view_unwind`).
- **Nested overrides restore out of order.** A pop out of order is an
  internal error, not a silent wrong answer.
- **A cache keeps a temporary answer.** Anything that memoizes per node
  caches only with no view open, or keys on `view_epoch()`.
- **An override is invisible.** Every one is on the stack, and `repr_of`
  stays a pure read of it, which `--repr-check` relies on.

So codegen changes how a node reads for one emission only through a view,
and never writes the node table or the analysis's answers itself. A fact a
view cannot yet carry gets a new kind of view.

## Reading a diff for the old way

A change that does any of these is asking a question one of the layers
already answers, or should:

- a new `comp_ntype` read in codegen, whether it decides layout or which
  emitter, builtin or target runs (a read whose type is the data, such as
  a diagnostic, is fine; say so);
- a call-plan or row change that records a decision for `--plan-check`
  while the emitter beside it still decides on its own;
- an inline `sp_streq(name, "...")` where a row or a predicate fits;
- a decision in a renderer that the String plan should make;
- a special case keyed on one method name;
- hand recursion over node kinds where a walker exists;
- a fact re-derived at one call site that a layer already answers.

## The verifiers

Each layer has a check that compares what it decided with what the
emitted C does. A change to a layer keeps its check at zero, or lowers
the count it reports.

| Verifier         | What it compares                                                                                                                      | How it runs                                                                           |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `--plan-check`   | the builtin-op row, the user method and the dispatch arms codegen emitted a call through, against the ones inference answered it with | `tools/plan_check.sh` over the corpus; a conflict fails                               |
| `--repr-check`   | codegen asks `repr_of` of every node it emits; the C must not change                                                                  | `make repr-check-test`                                                                |
| `--check-traits` | every column of the type traits table, rendered from the function it summarizes                                                       | `make traits-check-test`                                                              |
| `--check-stores` | each value written raw into a C slot of another C type                                                                                | `make check-stores-test`                                                              |
| value edges      | the generated table of how each node kind's parent uses its value, against its source                                                 | `make value-edges-check`                                                              |
| counted setters  | the tables `infer_type` reads are written only through their setters                                                                  | `make ty-setter-check`                                                                |
| incremental-test | an incremental build's binary against a from-scratch build's, and the misses of a local edit against a bound                          | `tools/incremental_test.sh` (`make incremental-test`)                                 |

The checks report; they do not decide. When a check and the C disagree
and the C is right, the layer's answer is what to fix, so the two agree.

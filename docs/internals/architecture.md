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
| a fact about one emission, or one poly arm's state                             | views and `ArmCtx`                                 | `codegen_view.c:view_push`, `view_push_repr`, `view_bind`, `view_push_arm`                                                                      | a node type overwritten in an emitter; a flag saved and restored by hand; a new `g_*` global                                         |
| membership in a family of names                                                | the name predicates                                | `builtin_names.c:is_call_alias`, `is_then_alias`, ...                                                                                           | the same inline `sp_streq` chain in inference and in codegen                                                                         |
| when a pass runs, and what inference reads                                     | the phase driver and the counted setters           | `analyze.c:analyze_program`; `comp_set_ntype`, `lv_set_type`, `ivar_set_type`                                                                   | a loop appended to `analyze_program`; a direct write to a table `infer_type` reads                                                   |

`comp_ntype` stays the answer to a semantic question (is this a String,
which class is the receiver); it cannot alone decide how a value is laid
out, which is `repr_of`'s answer.

## Reading a diff for the old way

A change that does any of these is asking a question one of the layers
already answers, or should:

- a new `comp_ntype` read in codegen that decides layout (a semantic-type
  question is fine; say which it is);
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
| `--share-check`  | each String the String plan needs as the object, against the conversion the emitter wrote                                             | `make share-check-ratchet`: its two lists, copies and plan disagreements, only shrink |
| `--check-stores` | each value written raw into a C slot of another C type                                                                                | `make check-stores-test`                                                              |
| value edges      | the generated table of how each node kind's parent uses its value, against its source                                                 | `make value-edges-check`                                                              |
| counted setters  | the tables `infer_type` reads are written only through their setters                                                                  | `make ty-setter-check`                                                                |

The checks report; they do not decide. When a check and the C disagree
and the C is right, the layer's answer is what to fix, so the two agree.

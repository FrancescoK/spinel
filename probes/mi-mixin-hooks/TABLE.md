# included, extended and prepended at the walk's mixin events: probe table

Recorded at master `94288ce9b`, macOS, Apple clang 21. `CRuby` is `ruby --enable-frozen-string-literal <probe>.rb` (CRuby 4.0), the same text as `<probe>.cruby`; lines are joined with ` / `. The other columns are `spinel --load-model=inline` and `--load-model=graph`: `ok` matches CRuby, `wrong` shows what the binary printed, `refused` is a compile-time refusal, `cerror` a compile failure without a refusal.

Re-run: `./run.sh path/to/spinel` (from a built checkout; `JOBS=4` for parallel compiles).

Counts:

- graph ok 12
- graph refused 5
- graph wrong 13
- inline ok 12
- inline refused 5
- inline wrong 13

| probe | CRuby | inline | graph |
|---|---|---|---|
| n01_incl_before | `inc A / done` | ok | ok |
| n02_incl_after | `inc B / done` | wrong: `inc A / inc B / done` | wrong: `inc A / inc B / done` |
| n03_incl_redef | `v1 A / v2 B` | wrong: `v1 A / v1 B` | wrong: `v1 A / v1 B` |
| n04_incl_removed | `inc A / done` | wrong: `inc A / inc B / done` | wrong: `inc A / inc B / done` |
| n05_ext_after | `ext B / done` | wrong: `ext A / ext B / done` | wrong: `ext A / ext B / done` |
| n06_prepended | `pre A / pre N C` | wrong: `` | wrong: `` |
| n07_incl_private | `inc A / false` | ok | ok |
| n08_incl_super | `inc A nil` | refused | refused |
| n09_incl_class_methods | `cm / im` | ok | ok |
| n10_incl_const | `1` | wrong: `uninitialized constant A::FROM_M (NameError)` | wrong: `uninitialized constant A::FROM_M (NameError)` |
| n11_incl_class_new | `inc nil / X` | ok | ok |
| n12_incl_struct | `inc Struct / 1` | ok | ok |
| n13_incl_module_in_module | `inc M2 / [A, M2, M]` | wrong: `[A, M2, M]` | wrong: `[A, M2, M]` |
| n14_incl_explicit_receiver | `inc K / true` | wrong: `true` | wrong: `true` |
| n15_incl_hook_from_extend | `hooked B / done` | wrong: `done` | wrong: `done` |
| n16_incl_graph_require | `inc B / done` | wrong: `inc A / inc B / done` | wrong: `inc A / inc B / done` |
| n17_incl_in_method | `inc A / inc B / true` | refused | refused |
| n18_incl_conditional | `done` | refused | refused |
| n19_ext_object | `ext Object / hi` | refused | refused |
| n20_incl_return | `inc B` | ok | ok |
| n21_incl_twice | `inc A / inc A` | ok | ok |
| n22_incl_order | `before / inc true / after` | ok | ok |
| n23_incl_redef_same_body | `v1 A / v2 M::Inner` | wrong: `v1 A / v1 M::Inner` | wrong: `v1 A / v1 M::Inner` |
| n24_incl_class_ivar | `[1, 2]` | ok | ok |
| n25_incl_builtin_reopen | `inc String / HI!` | ok | ok |
| n26_incl_extend_attrs | `3` | ok | ok |
| n27_incl_hook_after_in_lib_order | `inc A` | wrong: `inc A / inc A` | wrong: `inc A / inc A` |
| n28_incl_hook_ivar_count | `inc A 1 / inc B 2 / 2` | ok | ok |
| x01_hook_in_hook | `inh C / inc C / true` | refused | refused |
| x07_ext_self | `ext M / hi` | wrong: `hi` | wrong: `hi` |

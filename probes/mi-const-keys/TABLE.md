# Constant keys and slots from the load record: probe table

Recorded at master `94288ce9b`, macOS, Apple clang 21. `CRuby` is `ruby --enable-frozen-string-literal <probe>.rb` (CRuby 4.0), the same text as `<probe>.cruby`; lines are joined with ` / `. The other columns are `spinel --load-model=inline` and `--load-model=graph`: `ok` matches CRuby, `wrong` shows what the binary printed, `refused` is a compile-time refusal, `cerror` a compile failure without a refusal.

Re-run: `./run.sh path/to/spinel` (from a built checkout; `JOBS=4` for parallel compiles).

Counts:

- graph ok 11
- graph refused 1
- graph wrong 3
- inline ok 10
- inline refused 2
- inline wrong 3

| probe | CRuby | inline | graph |
|---|---|---|---|
| a1_defined_root_scoped | `:none` | ok | ok |
| a2_singleton_class_const | `1 / 2 / 1` | wrong: `2 / 2 / 2` | wrong: `2 / 2 / 2` |
| a3_nested_path_write | `1 / 2 / 3 / 3` | wrong: `2 / 2 / 3 / 3` | wrong: `2 / 2 / 3 / 3` |
| a4_class_new_block_const | `raises: uninitialized constant Y` | ok | ok |
| a5_array_loop_const_set | `[10, 11] / 4 / 10` | refused | refused |
| a6_hash_table_loop_const_set | `1 / 2 / 9` | refused | ok |
| a7_kernel_and_object_include_const | `42 / 42 / :m` | ok | ok |
| a8_read_before_shadowing_write | `[1, 2] / 1` | wrong: `uninitialized constant A::X (NameError)` | wrong: `uninitialized constant A::X (NameError)` |
| a9_defined_other_class_const | `:none / 5` | ok | ok |
| b1_path_write_through_superclass | `8 / 3` | ok | ok |
| b2_superclass_const_by_path | `3 / 7` | ok | ok |
| c1_reopened_class_collision | `3 / [3, 4] / 4 / 9` | ok | ok |
| c2_builtin_named_nested_const | `5 / 4` | ok | ok |
| g1_blockless_builder_path_write | `"white" / 7 / 8` | ok | ok |
| g2_struct_holder_beside_module | `1.5 / 10 / 20` | ok | ok |

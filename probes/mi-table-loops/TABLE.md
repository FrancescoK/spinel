# Table loops as a loop form of the walk: probe table

Recorded at master `94288ce9b`, macOS, Apple clang 21. `CRuby` is `ruby --enable-frozen-string-literal <probe>.rb` (CRuby 4.0), the same text as `<probe>.cruby`; lines are joined with ` / `. The other columns are `spinel --load-model=inline` and `--load-model=graph`: `ok` matches CRuby, `wrong` shows what the binary printed, `refused` is a compile-time refusal, `cerror` a compile failure without a refusal.

Re-run: `./run.sh path/to/spinel` (from a built checkout; `JOBS=4` for parallel compiles).

Counts:

- graph ok 8
- graph refused 3
- inline ok 3
- inline refused 8

| probe | CRuby | inline | graph |
|---|---|---|---|
| e1_values | `1 / 2` | refused | ok |
| e2_values_colliding_leaf | `1 / 2 / 9` | refused | ok |
| e3_classes | `1 / "Codes::Two" / Codes::Base` | ok | ok |
| e4_class_leaf_written_elsewhere | `Codes::Base / :top` | refused | ok |
| e5_inherited_defined_later | `inherited / Codes::Base` | refused | refused |
| e6_core_method_changed_later | `1 / :changed` | refused | refused |
| e7_const_set_defined_elsewhere | `1 / :mine` | refused | refused |
| e8_const_written_after_loop | `1` | refused | ok |
| e9_in_required_file | `3` | refused | ok |
| t_class_table_loop_status_classes | `200 / 414 / 404 / HTTPStatus::Success / HTTPStatus::Info / "Not Found" / 4 / nil / [HTTPStatus::Requ` | ok | ok |
| t_class_table_loop_values | `1 / "Two" / Codes::Base / "Two" / true / true / true / [1, 2] / "Codes::Two"` | ok | ok |

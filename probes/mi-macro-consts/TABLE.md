# Class-body macros that write constants: probe table

Recorded at master `94288ce9b`, macOS, Apple clang 21. `CRuby` is `ruby --enable-frozen-string-literal <probe>.rb` (CRuby 4.0), the same text as `<probe>.cruby`; lines are joined with ` / `. The other columns are `spinel --load-model=inline` and `--load-model=graph`: `ok` matches CRuby, `wrong` shows what the binary printed, `refused` is a compile-time refusal, `cerror` a compile failure without a refusal.

Re-run: `./run.sh path/to/spinel` (from a built checkout; `JOBS=4` for parallel compiles).

Counts:

- graph refused 13
- inline ok 13

| probe | CRuby | inline | graph |
|---|---|---|---|
| m1_const_set_macro | `32 / 32` | ok | refused |
| m2_state_then_const | `32 / :box` | ok | refused |
| m3_colliding_macro_consts | `32 / 4 / 32 / 4 / 1` | ok | refused |
| m4_read_before_macro_point | `:none / 32` | ok | refused |
| m5_state_merged_under_if | `8` | ok | refused |
| m6_const_set_inspect | `"\"a\\e#b\"" / "\"ab\""` | ok | refused |
| t_class_body_macro_builtin_literal | `{1 => 2, 2 => 1} / 64 / 64` | ok | refused |
| t_class_body_macro_expansion | `[[:int, :int], 5] / 9 / [32, 24] / 2 / 1 / 65 / 10 / 20 / "got-K" / 1 / 2 / :z` | ok | refused |
| t_class_body_macro_long_elsif | `1 / 3 / :a` | ok | refused |
| t_class_body_macro_reverse | `42 / "size"` | ok | refused |
| t_class_body_macro_scoped_alias | `1 / 1` | ok | refused |
| t_class_body_macro_state | `[32, 24] / :box / 4 / :small / 8 / 1 / 16 / 32 / :curve` | ok | refused |
| t_macro_inspect_runtime | `"\"a\\e#b\\r\"" / "\"ab\"" / "[:+, :@x, :[]]" / "[:a, :b?]"` | ok | refused |

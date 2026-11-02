# Definition forms recorded by the walk: probe table

Recorded at master `94288ce9b`, macOS, Apple clang 21. `CRuby` is `ruby --enable-frozen-string-literal <probe>.rb` (CRuby 4.0), the same text as `<probe>.cruby`; lines are joined with ` / `. The other columns are `spinel --load-model=inline` and `--load-model=graph`: `ok` matches CRuby, `wrong` shows what the binary printed, `refused` is a compile-time refusal, `cerror` a compile failure without a refusal.

Re-run: `./run.sh path/to/spinel` (from a built checkout; `JOBS=4` for parallel compiles).

Counts:

- graph cerror 4
- graph ok 13
- graph refused 2
- graph wrong 7
- inline cerror 4
- inline ok 13
- inline refused 2
- inline wrong 7

| probe | CRuby | inline | graph |
|---|---|---|---|
| a20_cbs_inherited | `1 / nil / 1` | ok | ok |
| a21_cbs_order | `:base / :sub / :sub` | ok | ok |
| a22_cbs_block_self | `11 / nil / 11` | ok | ok |
| a23_ied_const | `:nomethod / :m` | ok | ok |
| a24_ied_object | `:om` | cerror | cerror |
| a25_ied_body | `:km / :km` | ok | ok |
| a26_bme_self | `:a / :b` | refused | refused |
| a26b_bme_local | `:b` | refused | refused |
| a26c_bme_selfonly | `:a / :a` | ok | ok |
| a27_bme_locals | `5 / nil` | ok | ok |
| a28_emb_class_eval | `adding to K / :done` | ok | ok |
| a29_emb_exec | `[Helper, 1, 2] / [Helper, :x, :y]` | wrong: `[Helper, 1, 2] / wrong argument type Symbol (expected Integer) (TypeError)` | wrong: `[Helper, 1, 2] / wrong argument type Symbol (expected Integer) (TypeError)` |
| a30_cbo_acts | `B / "B" / false / true / [] / [:m]` | wrong: `B / "B" / false / true / [:m] / [:m]` | wrong: `B / "B" / false / true / [:m] / [:m]` |
| a31_cbo_shadow | `"custom" / "C" / "late"` | ok | ok |
| a32_cbo_struct | `[:x, :y] / nil / 1` | ok | ok |
| b01_sc_attr | `5 / [:x, :x=] / true` | wrong: `5 / [:x, :x=] / false` | wrong: `5 / [:x, :x=] / false` |
| b02_sc_attr_vs_def | `true / true / 7 / 3 / [:x, :y]` | wrong: `false / true / 7 / 3 / [:x, :y]` | wrong: `false / true / 7 / 3 / [:x, :y]` |
| b03_sc_attr_order | `false / true / 1 / {a: 1} / 9 / true` | cerror | cerror |
| b04_sc_attr_bodycall | `1 / 9` | cerror | cerror |
| b05_def_self_bodycall_ctrl | `1 / 9` | ok | ok |
| b21_undef_method | `true / false / false / 10 / false / undefined method 'b' for an instance of Q / 2` | wrong: `false / false / false / undefined method 'a' for an instance of Q (NoMethodError)` | wrong: `false / false / false / undefined method 'a' for an instance of Q (NoMethodError)` |
| b22_undef_kw_ctrl | `true / 10` | wrong: `false / undefined method 'a' for an instance of Q (NoMethodError)` | wrong: `false / undefined method 'a' for an instance of Q (NoMethodError)` |
| b26_sc_attr_nosub | `1 / 1` | cerror | cerror |
| b27_def_self_nosub_ctrl | `1 / 1` | ok | ok |
| b28_sclass_attr_ctrl | `1 / 2 / 9 / [:x, :x=]` | ok | ok |
| m15_ma_class_eval | `added z / true` | wrong: `true` | wrong: `true` |

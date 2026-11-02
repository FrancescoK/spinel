# Mixins recorded by the walk: probe table

Recorded at master `94288ce9b`, macOS, Apple clang 21. `CRuby` is `ruby --enable-frozen-string-literal <probe>.rb` (CRuby 4.0), the same text as `<probe>.cruby`; lines are joined with ` / `. The other columns are `spinel --load-model=inline` and `--load-model=graph`: `ok` matches CRuby, `wrong` shows what the binary printed, `refused` is a compile-time refusal, `cerror` a compile failure without a refusal.

Re-run: `./run.sh path/to/spinel` (from a built checkout; `JOBS=4` for parallel compiles).

Counts:

- graph ok 6
- graph refused 5
- graph wrong 7
- inline ok 6
- inline refused 5
- inline wrong 7

| probe | CRuby | inline | graph |
|---|---|---|---|
| a01_recv_prepend | `"K" / "MK" / [M, K, Object]` | ok | ok |
| a02_recv_include_block | `"M"` | refused | refused |
| a03_send_include_order | `false / true / "M"` | wrong: `true / true / "M"` | wrong: `true / true / "M"` |
| a03b_body_include_order | `false / true` | wrong: `true / true` | wrong: `true / true` |
| a04_req_prepend | `"K" / "MK"` | ok | ok |
| a05_sclass_prepend_order | `"K" / "M>K" / "M>K" / [M, #<Class:K>]` | refused | refused |
| a05b_sclass_prepend_order | `"K" / "M>K" / "M>K"` | wrong: `"M>K" / "M>K" / "M>K"` | wrong: `"M>K" / "M>K" / "M>K"` |
| a06_sclass_include_hook | `included in #<Class:K> / "M"` | refused | refused |
| a07_sclass_include_after_run | `false / false / "M"` | refused | refused |
| a08_extend_self_order | `1 / :nameerr / 2 / 1 / 2` | wrong: `1 / 2 / 2 / 1 / 2` | wrong: `1 / 2 / 2 / 1 / 2` |
| a08b_extend_self_late | `:nomethod / 1` | wrong: `1 / 1` | wrong: `1 / 1` |
| a08c_control_cmethod_order | `:nameerr / 2` | ok | ok |
| a09_extend_self_own | `:own / :n / 3 / :inst` | ok | ok |
| a10_extend_self_req | `:a / :b` | ok | ok |
| a11_extend_enum | `[2, 4, 6] / 1 / true / [[1, 2], [3]] / true` | ok | ok |
| a12_extend_enum_order | `:nomethod / 2 / [:a, :b]` | wrong: `2 / 2 / [:a, :b]` | wrong: `2 / 2 / [:a, :b]` |
| a39_erm_in_body | `:m / true` | refused | refused |
| x07_ext_self | `ext M / hi` | wrong: `hi` | wrong: `hi` |

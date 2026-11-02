--- table
| probe | CRuby | inline | graph |
|---|---|---|---|
| c1_read_before_nested_leaf | `:top / :m` | wrong: `:m / :m` | wrong: `:m / :m` |
| c2_builtin_parent_bare_leaf | `:name_error` | wrong: `:sh` | wrong: `:sh` |
| c3_builtin_parent_defined | `nil` | wrong: `"constant"` | wrong: `"constant"` |
| c4_builtin_parent_beside_leaf | `:s / :m` | refused | refused |
| c5_alias_rewritten | `1 / 2` | wrong: `1 / 1` | wrong: `1 / 1` |
| c6_alias_after_header | `:foo / :a` | wrong: `uninitialized constant A (NameError)` | wrong: `uninitialized constant A (NameError)` |
| k1_top_and_nested_leaf | `:top / :m / :m` | ok | ok |
| k2_struct_consts_same_leaf | `[:x] / [:y]` | ok | ok |
| k3_alias_same_leaf_two_modules | `:red / :blue` | ok | ok |
| k4_when_same_leaf | `:b` | ok | ok |
| k5_nested_builtin_module | `false` | ok | ok |
| n1_method_read_later_leaf | `:top / :m` | wrong: `:m / :m` | wrong: `:m / :m` |

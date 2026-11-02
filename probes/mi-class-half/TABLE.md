--- table
| probe | CRuby | inline | graph |
|---|---|---|---|
| p01_nested_builtin_module | `false / [:hi]` | ok | ok |
| p02_nested_math_module | `6 / false` | ok | ok |
| p03_builtin_parent_beside_leaf | `:string_helper / :m_helper` | refused | refused |
| p04_bare_leaf_outside_namespace | `NameError / :hi` | ok | ok |
| p05_alias_after_header | `:foo / :a` | wrong: `uninitialized constant A (NameError)` | wrong: `uninitialized constant A (NameError)` |
| p06_alias_in_other_scope | `5 / 50` | ok | ok |
| p07_top_and_nested_same_leaf | `:top / :m / :m` | ok | ok |
| p08_qualified_name_taken | `:plain / :nested` | ok | ok |
| p09_struct_const_two_modules | `1 / 2 / [:x] / [:y]` | ok | ok |
| p10_path_leaf_shared_rescue | `[:b, "b"]` | ok | ok |
| p11_case_when_alias_later | `:pet / :other` | ok | ok |
| p12_nested_class_named_like_const | `1 / :rack` | ok | ok |
| p13_builtin_parent_bare_leaf | `NameError / :sh / :mh` | wrong: `:sh / :sh / :mh` | wrong: `:sh / :sh / :mh` |
| p14_alias_read_before_write_in_module | `:impl` | ok | ok |
| p15_alias_superclass | `:base / M::Base` | ok | ok |
| p16_alias_raise | `M::E` | ok | ok |
| p17_alias_rewritten | `1 / 2` | wrong: `1 / 1` | wrong: `1 / 1` |
| p18_alias_in_method_later | `1` | ok | ok |
| p19_two_modules_alias_same_name | `:red / :blue / :red / :blue` | ok | ok |
| p20_include_alias_two_modules | `:a / :b` | ok | ok |
| p21_read_before_nested_leaf | `:top / :m` | wrong: `:m / :m` | wrong: `:m / :m` |
| p22_method_reads_later_nested_leaf | `:top / :m` | wrong: `:m / :m` | wrong: `:m / :m` |
| p23_builtin_parent_alone_bare | `:unit / nil` | wrong: `:unit / "constant"` | wrong: `:unit / "constant"` |
| p24_when_two_same_leaf | `:b / :a / false` | ok | ok |

# Probe programs for #10719 (a block call a reopened Array iterator takes)

68 programs. Each `name.rb.expected` is CRuby 4.0's output (`ruby --enable-frozen-string-literal name.rb`, run from this directory).

The table was recorded when the issue was written. `master` is `3732f51dc`, and `narrow fix` is that master plus the commit on the fork's `fix-reopen-capture` branch. Each cell has four answers: inline / `--load-model=graph` / `--int-overflow=promote` / `SPINEL_GC_STRESS=1` (inline). `ok` is CRuby's output, `REF` is a compile-time refusal, and `W…` is a wrong output (a prefix of its hash).

| program | master | narrow fix |
|---|---|---|
| `a1_keep_chg_reopen_ewo` | REF/REF/REF/REF | ok/ok/ok/ok |
| `a2_keep_chg_reopen_ewo_kw` | REF/REF/REF/REF | ok/ok/ok/ok |
| `b1_iter_chg_between` | REF/REF/REF/REF | ok/ok/ok/ok |
| `b2_iter_chg_between_kw` | REF/REF/REF/REF | ok/ok/ok/ok |
| `c1_iter_chg_before` | REF/REF/REF/REF | ok/ok/ok/ok |
| `d1_setter` | REF/REF/REF/REF | ok/ok/ok/ok |
| `d2_ivar_set` | REF/REF/REF/REF | ok/ok/ok/ok |
| `d3_other_obj` | REF/REF/REF/REF | ok/ok/ok/ok |
| `e1_noyield_missing` | ok/ok/ok/ok | ok/ok/ok/ok |
| `e2_noyield_count` | W816d/W816d/W816d/W816d | W816d/W816d/W816d/W816d |
| `e3_method_override_count` | REF/REF/REF/REF | Wfefd/Wfefd/Wfefd/Wfefd |
| `e4_nil_recv` | REF/REF/REF/REF | W6b5a/W6b5a/W6b5a/W6b5a |
| `e5_noyield_nil_recv` | W2866/W2866/W2866/W2866 | W2866/W2866/W2866/W2866 |
| `e6_empty_missing` | REF/REF/REF/REF | REF/REF/REF/REF |
| `f1_global_recv` | REF/REF/REF/REF | ok/ok/ok/ok |
| `f2_closure_local` | REF/REF/REF/REF | ok/ok/ok/ok |
| `f3_ivar_name` | REF/REF/REF/REF | ok/ok/ok/ok |
| `f4_global_keep_chg` | REF/REF/REF/REF | ok/ok/ok/ok |
| `g_each_reopen_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `g_ewi_reopen_keepchg` | REF/REF/REF/REF | REF/REF/REF/REF |
| `g_inject_reopen_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `g_map_reopen_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `h_each_builtin_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `h_ewi_builtin_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `h_inject_builtin_keepchg` | Wac27/Wac27/Wac27/Wac27 | Wac27/Wac27/Wac27/Wac27 |
| `h_map_builtin_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `i_each_otherclass_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `i_ewi_otherclass_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `i_ewo_otherclass_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `i_ewo_otherclass_keepchg_kw` | ok/ok/ok/ok | ok/ok/ok/ok |
| `i_inject_otherclass_keepchg` | W6958/W6958/W6958/W6958 | W6958/W6958/W6958/W6958 |
| `i_map_otherclass_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `j1_module_included_ewo` | REF/REF/REF/REF | ok/ok/ok/ok |
| `j2_enumerable_reopen_ewo` | ok/ok/ok/ok | ok/ok/ok/ok |
| `j3_prepend_ewo` | REF/REF/REF/REF | ok/ok/ok/ok |
| `j4_refine_ewo` | REF/REF/REF/REF | REF/REF/REF/REF |
| `j5_module_included_ewo_nochg` | REF/REF/REF/REF | ok/ok/ok/ok |
| `j6_enumerable_reopen_nochg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `k1_userclass_ewo_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `k2_userclass_ewo_argchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `k3_userclass_each_keepchg` | ok/ok/ok/ok | ok/ok/ok/ok |
| `l1_pr_pos` | REF/REF/REF/REF | ok/ok/ok/ok |
| `l2_pr_kw` | REF/REF/REF/REF | Wa503/Wa503/Wa503/Wa503 |
| `l3_reopen_all_elems_argchg` | REF/REF/REF/REF | ok/ok/ok/ok |
| `l4_reopen_nochg` | REF/REF/REF/REF | ok/ok/ok/ok |
| `l5_reopen_self_lookup` | ok/ok/ok/ok | ok/ok/ok/ok |
| `l6_value_pos` | REF/REF/REF/REF | ok/ok/ok/ok |
| `n1_local_capture` | REF/REF/REF/REF | REF/REF/REF/REF |
| `n2_mk_lookup` | REF/REF/REF/REF | ok/ok/ok/ok |
| `n3_reopen_after` | REF/REF/REF/REF | W3acf/W3acf/W3acf/W3acf |
| `table` | ok/ok/ok/ok | ok/ok/ok/ok |
| `g1` | W7c5a/W7c5a/W7c5a/W7c5a | W7c5a/W7c5a/W7c5a/W7c5a |
| `l1c` | REF/REF/REF/REF | REF/REF/REF/REF |
| `l1d` | REF/REF/REF/REF | REF/REF/REF/REF |
| `n1b` | W6b5a/W6b5a/W6b5a/W6b5a | W6b5a/W6b5a/W6b5a/W6b5a |
| `q01_append_builtin` | ok/ok/ok/ok | ok/ok/ok/ok |
| `q02_append_reopen` | REF/REF/REF/REF | ok/ok/ok/ok |
| `q03_lambda_wrap` | REF/REF/REF/REF | ok/ok/ok/ok |
| `q04_times_loop` | REF/REF/REF/REF | W6957/W6957/W6957/W6957 |
| `q05_toplevel` | REF/REF/REF/REF | REF/REF/REF/REF |
| `q06_fill_nilable` | ok/ok/ok/ok | ok/ok/ok/ok |
| `q07_builtin_map_value` | We1df/We1df/We1df/We1df | We1df/We1df/We1df/We1df |
| `q08_user_yield_spliced` | ok/ok/ok/ok | ok/ok/ok/ok |
| `q09_fiber` | REF/REF/REF/REF | ok/ok/ok/ok |
| `q10_int_memo` | REF/REF/REF/REF | ok/ok/ok/ok |
| `q11_hash_reopen` | Wb42a/Wb42a/ok/Wb42a | Wb42a/Wb42a/ok/Wb42a |
| `q12_flat_map_reopen` | REF/REF/REF/REF | ok/ok/ok/ok |
| `q13_gc_many` | REF/REF/REF/REF | ok/ok/ok/ok |

# K-035: four more names on a `yield` receiver still produced invalid C or
# the wrong per-site answer once K-034 landed -- same family (K-029/K-030/
# K-033/K-034), four different exact gaps this time.
#
# *(n): Array#*(Integer/Float) already answered the right STATIC type on
# a direct call (analyze_infer.c), and the per-site answer for a yield's
# scalar sites (Integer/Float/String) already worked too -- but
# yield_operator_site_type (codegen_util.c), which recovers each site's
# own answer so it can be boxed into the method's shared poly slot, had no
# Array arm at all. The site's own array pointer value got assigned into
# the slot unboxed, which did not compile.
#
# +@: never gated in yield_site_listed at all (unlike -@, already there),
# and its own bop_rows row for a String receiver was a TY_UNKNOWN
# placeholder, not yet a real answer -- both fixed alongside each other,
# mirroring -@ exactly.
#
# prepend (0-arg, no values): Array's own row was a TY_UNKNOWN placeholder
# ("no values: self, or FrozenError" was never written for it, unlike
# insert's identical case) -- fixed with a new row mirroring insert's.
#
# slice!(start, length): the two-argument form's own TYPE answer is fixed
# by a one-line allowlist addition (same mechanism as every other name in
# this family) -- but a String site specifically fell through a different,
# deeper gap: the dedicated two-argument string-slice emitter
# (emit_op_string_slice, codegen_call_string.c) only emits for a receiver
# expression str_fresh_value recognizes as "no other name can hold" (an
# interpolation, a `+"..."` copy, ...) OR one that is itself a plain
# variable (str_mut_var_recv) -- a `yield` receiver was neither, since
# str_fresh_value never looked through a yield to the block's own tail
# expression at that site the way sp_yield_site_type's per-site lookup
# does. Fixed by making str_fresh_value do the identical lookup
# (g_block_id's own tail, forwarded through any `wrap { yield }` level)
# and ask the SAME question about what it finds.
def t_star = yield.*(2)
p t_star { 7 }
p t_star { 2.5 }
p t_star { "abc" }
p t_star { [3, 1, 2] }
p t_star { ["b", "a"] }

def t_plusat = yield.+@
p t_plusat { 7 }
p t_plusat { 2.5 }
p t_plusat { "abc" }

def t_prepend = yield.prepend
p t_prepend { +"abc" }
p t_prepend { [3, 1, 2] }
p t_prepend { ["b", "a"] }

def t_slice_bang_2 = yield.slice!(1, 2)
p t_slice_bang_2 { +"abc" }
p t_slice_bang_2 { [3, 1, 2] }
p t_slice_bang_2 { ["b", "a"] }

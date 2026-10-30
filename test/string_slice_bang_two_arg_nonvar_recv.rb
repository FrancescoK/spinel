# frozen_string_literal: true
# slice!(start, length) on a String receiver that is NEITHER a variable
# (no lvalue to write a mutated copy back to) NOR one of the handful of
# shapes str_fresh_value recognizes as "no other name holds this value"
# (a literal, a ternary between two literals, ...) used to fall straight
# through emit_op_string_slice to the unresolved-call gate and raise
# NoMethodError, as if String had no slice! at all. The 1-argument form
# (slice!(i)) never had this gap: it runs unconditionally and lets
# sp_str_check_mutable raise FrozenError for a literal, same as any other
# frozen-String mutator. The 2-argument form answers the same way now.
begin
  "abc".slice!(1, 2)
rescue FrozenError => e
  puts e.message
end
begin
  (true ? "abc" : "def").slice!(1, 2)
rescue FrozenError => e
  puts e.message
end

p (true ? +"abc" : +"def").slice!(1, 2)
p "x".dup.concat("abc").slice!(1, 2)

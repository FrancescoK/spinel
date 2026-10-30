# A yield's argless #flatten, mixed across call sites of differing block
# kind (a poly array beside a plain typed array), boxes the typed array's
# self-elision into the shared poly slot instead of leaving its raw typed
# pointer assigned there. The one-argument form (flatten(1)) already boxed
# this combination correctly; flatten() took a different, narrower codegen
# arm (emit_op_array_flatten's argc == 0 branch) that assumed the result
# stayed the receiver's own typed-array kind, which is only true at a
# single site -- across two sites of differing kind the shared slot is a
# poly array, and the typed array must be rebuilt into one.
def t_flatten_noarg = yield.flatten

p t_flatten_noarg { [[1, 2], [3, 4]] }
p t_flatten_noarg { [3, 1, 2] }

# The conversion this mix needs (a typed array rebuilt into the shared poly
# slot) must not reuse the generic widening helper used elsewhere
# (emit_array_into_poly_slot) unchecked: that helper copies the receiver's
# frozen flag (right for a widening read, wrong for flatten, which always
# answers a fresh, mutable copy -- even of a frozen receiver's) and turns a
# NULL receiver into an empty poly array instead of raising NoMethodError
# (reachable through an out-of-range slice on a typed array). Caught rather
# than left to propagate, so the snapshot stays a stdout-only comparison
# across compilers whose uncaught-exception backtraces are not byte-identical.
frozen = [1, 2, 3].freeze
r2 = t_flatten_noarg { frozen }
p r2.frozen?
r2 << 99
p r2

a = [1, 2, 3]
begin
  t_flatten_noarg { a[10..20] }
  puts "did not raise"
rescue NoMethodError => e
  puts "caught: #{e.class}"
end

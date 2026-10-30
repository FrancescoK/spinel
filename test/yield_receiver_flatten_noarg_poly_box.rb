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

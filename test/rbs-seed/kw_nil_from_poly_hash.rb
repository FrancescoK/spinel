# A keyword parameter an RBS declaration pins to a nilable Integer or Float,
# read out of a `**` operand only the run time knows as a Hash (a boxed
# value), took nil as 0 or 0.0: emit_ds_param_extract's bare-poly lookup
# unboxed it through the bare payload rather than keeping nil as the slot's
# own nil. A key the Hash lacks still takes the default.
# spinel: rbs-seed-check
def kwnp_int(k1: 70) = [k1]
def kwnp_flt(k1: 1.5) = [k1]
x = [{ k1: nil }, 1, {}]
h = x[0]
e = x[2]
p kwnp_int(k1: 5)
p kwnp_int(**h)
p kwnp_int(**e)
p kwnp_flt(k1: 2.5)
p kwnp_flt(**h)
p kwnp_flt(**e)

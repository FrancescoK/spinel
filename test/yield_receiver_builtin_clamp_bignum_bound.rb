# clamp(lo, hi) on a yield receiver, with a Bignum bound: a pre-existing
# codegen gap (never reached by a plain `n.clamp(...)` call, which always
# resolves through Comparable#clamp -- this per-call-site builtin dispatch
# is reached only via a yield receiver, int_arms_clamp_pow/the Float arms
# in codegen_call_recv.c). The Integer-receiver arm had a hand-written
# Bignum-bound branch (#3006) that assumed any Bignum bound exceeds every
# sp_int receiver and, when the bound itself won, truncated it back to an
# sp_int with sp_bigint_to_int -- wrong whenever the Bignum's actual value
# is small (`x - x + 1000` stays typed Bignum however small it computes to)
# and, for a bound that genuinely doesn't fit int64, emitted a bare sp_int
# where the call site (poly, since ty_recv_builtin_result answers poly for
# any non-receiver-kind bound) needed a boxed sp_RbVal -- a C compile
# error ("assigning to 'sp_RbVal' from incompatible type 'sp_int'"). The
# Float-receiver arm had no Bignum-bound case at all and raised
# NoMethodError for a call CRuby answers. Both are fixed by folding the
# Bignum bound into the existing boxed sp_num_clamp path each receiver
# already uses for a Float/poly/Rational bound.
def w
  yield.clamp($lo, $hi)
end

x = 10**30
$lo = x
$hi = x + 1000

# forces a second, differing-kind call site so the yield receiver's clamp
# is dispatched per call site rather than resolved to a single concrete type
p w { 1 }
p w { 1.5 }

# a Bignum bound whose actual runtime value is small: the receiver can fall
# inside, at, or below it, unlike a bound that genuinely exceeds int64
$lo = x - x + 1000
$hi = x - x + 2000
p w { 1 }
p w { 1500 }
p w { 3000 }
p w { 1.0 }
p w { 1500.0 }
p w { 3000.0 }

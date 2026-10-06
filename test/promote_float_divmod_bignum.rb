# spinel: int64
# A typed Float#divmod quotient past the machine word is a Bignum under
# --int-overflow=promote, as the typed floor's is (promote_float_to_int);
# raise mode keeps the RangeError float_to_int_out_of_range pins. The
# typed arms cast floor(x / y) to sp_int, which answered 0 for
# 5.divmod(1e-300), and raised for 1e20.divmod(3).
p 1e20.divmod(3)
p 5.divmod(1e-300)
p (-(2.0**70)).divmod(7.0)
f = 2.0**70
p f.divmod(1.0)

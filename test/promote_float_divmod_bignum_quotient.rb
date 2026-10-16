# spinel: int64
# Under --int-overflow=promote a Float#divmod quotient past int64 is a
# Bignum, as CRuby answers; the default mode raises RangeError there, as
# Float#floor does (test/float_to_int_out_of_range.rb).
p 1e20.divmod(3.0)
p((-1e20).divmod(7.0))
x = 2**62
p x.divmod(0.1)
p 7.5.divmod(2.0)

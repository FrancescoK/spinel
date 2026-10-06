# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# A Bignum read out of a box converts to a Float by its value for a Math
# function. sp_num_to_f narrowed it to an sp_int first, so 10**30 wrapped
# and Math.sqrt answered 2253207551.5374217.
xs = [10**30, 2**70]
p Math.sqrt(xs[0])
p Math.sqrt(xs[1])
p Math.log10(xs[0])

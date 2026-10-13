# spinel: int64 -- the values are Bignums
# spinel: gc-stress
# Integer#to_s(base) of a Bignum answers a String the collector owns. The
# emitted call copied it again (sp_str_dup_external), and that copy's
# allocation could collect the answer before it was copied: under
# SPINEL_GC_STRESS=2 the results held freed bytes.
x = 10**30
x += ARGV.size
r = []
20.times { |i| r << (x + i).to_s(7) }
p r.last, r.uniq.size
p (x * x).to_s(36), (-x).to_s(2).size, x.to_s(16)

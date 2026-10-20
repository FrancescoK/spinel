# spinel: not-cruby -- a Float#to_r whose exact denominator is past sp_int is the closest Rational that fits
# A Float's exact rational value where its terms fit, as CRuby answers; a
# fraction finer than the denominator can hold (past 2^63, past 2^31 on a
# 32-bit build) is the closest rational whose terms fit, rather than a
# RangeError: spinel's Rational is a pair of machine Integers outside
# --int-overflow=promote. What holds on any build is checked here.
p 0.5.to_r, 0.375.to_r, -0.75.to_r, 3.0.to_r
r = 1e-30.to_r
p r == 0, r.denominator > 0
[2.5e-10, -1e-5, 1e-12, 0.1, 1.0 / 3].each do |x|
  q = x.to_r
  p [(q - x).abs <= x.abs * 1e-6 || (q - x).abs < 1e-9, q.denominator > 0]
end

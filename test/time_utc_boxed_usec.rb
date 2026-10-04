# Time.utc / Time.local's seventh argument, the microseconds, may be any
# real number known only at run time: an Integer, a Float or a Rational.
# activesupport's TimeZone#utc_to_local passes `t.sec_fraction * 1_000_000`.
# The boxed value went where an integer was expected, and the C did not
# compile.
def usec_of(i) = [250, 2.5, Rational(1, 3) * 1_000_000][i]
3.times do |i|
  t = Time.utc(2000, 1, 2, 3, 4, 5, usec_of(i))
  p [t.sec, t.nsec]
end
p Time.local(2000, 1, 2, 3, 4, 5, usec_of(0)).usec

# A Rational or a Complex held boxed (read out of a mixed Array) answers as
# a typed one does: it is frozen, it is a Numeric to a class computed at run
# time, eql? holds only within its class, Time + it keeps the fraction of a
# second, #i makes the Complex, and a digit count that is no Integer is
# CRuby's "not an integer" for round and its kin
def boxed_class(v, unused = nil) = v
boxed_class(3)
def t(label)
  p [label, yield]
rescue => e
  puts "#{label}: #{e.class}: #{e.message}"
end
r = [Rational(3, 4), 1][0]
one = [Rational(1, 1), 1][0]
z = [Complex(1, 2), 1][0]
t(:frozen) { [r.frozen?, z.frozen?] }
t(:is_a) { [r.is_a?(boxed_class(Numeric)), r.instance_of?(boxed_class(Rational)), r.is_a?(boxed_class(Comparable))] }
t(:complex_is_a) { [z.is_a?(boxed_class(Numeric)), z.instance_of?(boxed_class(Complex))] }
t(:eql) { [one.eql?([1, 2][0]), one.eql?(Rational(1, 1)), one == 1] }
time = Time.at(0)
t(:time) { [(time + r).subsec, (time + one).to_i] }
t(:time_str) { time + [r, "s"][1] }
t(:i) { [1, 2.0][0].i }
[[:nil, nil], [:true, true], [:str, "1"], [:flt, 1.5], [:one, 1]].each do |k, d|
  t("round #{k}") { r.round(d) }
  t("floor #{k}") { r.floor(d) }
end
t(:float_round) { [2.25, 1][0].round([1, nil][0]) }

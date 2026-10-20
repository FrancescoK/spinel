# A value read out of a mixed Array is held boxed, and the calls it reaches
# there answer as they do for the typed value: a fold over boxed Rationals
# keeps them, Time.utc keeps a boxed fraction of a second, zip / concat take
# no value without #each / an Array, a KeyError names the key as given, a
# number compares with an object through its #coerce, Float#divmod takes a
# boxed divisor, and a Float's rationalize asks its epsilon for #abs.
def t(label)
  p [label, yield]
rescue => e
  puts "#{label}: #{e.class}: #{e.message}"
end
class Bound
  def initialize(v) = @v = v
  def coerce(v) = [@v, v]
end
a = [Rational(1, 2), 1][0]
b = [Rational(1, 4), 1][0]
q = [Rational(1, 2), "s"][0]
s = [:s, 1][0]
h = {"a" => 1}
t(:reduce) { [a, b].reduce(0, :+) }
t(:sum) { [a, b].sum }
t(:time_sec) { Time.utc(2020, 1, 1, 0, 0, [Rational(3, 2), 1][0]).subsec }
t(:time_flt) { Time.utc(2020, 1, 1, 0, 0, [2.5, 1][0]).subsec }
t(:zip) { [[1], [2]].zip(q) }
t(:concat) { [1, 2].concat(q) }
t(:concat_value) { x = [1, 2]; x.concat(q); x }
t(:fetch) { h.fetch(q) }
t(:fetch_sym) { h.fetch(s) }
t(:fetch_values) { h.fetch_values(q) }
t(:between) { a.between?(Bound.new(0.25), Bound.new(1.0)) }
t(:lt) { a < Bound.new(2.0) }
t(:divmod) { 7.5.divmod(a) }
t(:rat_nil) { [0.1, 1][0].rationalize([nil, 1][0]) }
t(:rat_complex) { Rational(1, 3).rationalize([Complex(0.01, 0.01), 1][0]) }

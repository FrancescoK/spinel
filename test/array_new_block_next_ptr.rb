# `next v` in an Array.new block whose result is a narrowed pointer array
# (an object array, an int-array table) is that element's value too.
class Foo
  attr_reader :v
  def initialize(v) = @v = v
end
a = Array.new(3) { |i| next Foo.new(-1) if i == 0; Foo.new(i) }
p a.map(&:v)
d = Array.new(4) { |i| next nil if i == 1; next if i == 3; Foo.new(i) }
p d.map { |x| x&.v }
b = Array.new(3) { |i| next [9, 9] if i == 0; [i, i] }
p b, b[0].sum
c = Array.new(3) { |i| next nil if i == 2; Array.new(2) { |j| next -j if j.odd?; i + j } }
p c

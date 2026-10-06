# An empty `[]` written to a local where the write is itself a value is
# built at the local's representation, as the statement form builds it.
# Array.new's block emits its non-tail statements as values, so a local
# there that later holds a mixed or a Float array took the literal's own
# Integer array and the C build failed; the same write in parentheses or
# under a modifier `if` did too, and so into an Array of Arrays or objects.

p Array.new(3) { |i| y1 = [] if i == 0; y1.inspect }
p Array.new(3) { |i| if i == 1 then y2 = [] end; y2.inspect }
p Array.new(2) { |i| y3 = [] if i == 0; y3 ||= [1.5]; y3 }
p Array.new(2) { |i| Array.new(2) { |j| y4 = [] if j == 0; y4.inspect } }
f = -> { Array.new(2) { |i| y5 = [] if i == 0; y5 ||= [:s]; y5 } }
p f.call

z6 = (y6 = [])
y6 = [1, "a"]
p y6, z6
p((y7 = [] if true))
y7 = [2.5]
p y7
p Array.new(2) { |i| y8 = [] if i == 0; y8 ||= [[1]]; y8 << [i]; y8 }
class Pt
  def initialize(v) = (@v = v)
  attr_reader :v
end
z9 = (y9 = [])
y9 << Pt.new(4)
p y9.map(&:v), z9.size

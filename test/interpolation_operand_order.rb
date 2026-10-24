# An interpolated String runs before the operands to its right
# A recursive lambda answers a boxed value, which `+`, `<<` and the
# String methods convert to a String in a hold ahead of the call. The
# interpolation on the left was not bound in order with it, so the
# conversion ran the lambda first: `"k#{t(1)}" + g.call(d + 1)` printed
# the lambda's line before t(1)'s, and a generator drawing random numbers
# that way built different data than CRuby. CRuby runs the receiver, then
# each argument.
def t(n) = (puts "t#{n}"; n)

g = nil
g = ->(d) { puts "g#{d}"; d > 0 ? "x" : "k#{t(1)}" + g.call(d + 1) }
p g.call(0)

s = nil
s = ->(d) { puts "s#{d}"; d > 0 ? "x" : "k#{t(2)}" << s.call(d + 1) }
p s.call(0)

e = nil
e = ->(d) { puts "e#{d}"; d > 0 ? "x" : "k#{t(3)}".include?(e.call(d + 1)) }
p e.call(0)

# drawing in Ruby's order: the key's number, then the nested value's
x = 7
draw = -> { x = (x * 75 + 74) % 65537; x % 10 }
gen = nil
gen = ->(d) { d > 1 ? "v#{draw.call}" : "{k#{draw.call}: " + gen.call(d + 1) + "}" }
p gen.call(0)

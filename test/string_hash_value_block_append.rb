# A block that appends to a Hash's value appends to the String the Hash
# stores -- the caller's, when one was put in: through each_value, the value
# of each / each_pair, and an element of `values`, of a Hash local or a
# Hash literal. The block's parameter was bound to a copy, so the Hash and
# the caller kept their bytes.
s1 = +"a"
h1 = { k: s1 }
h1.each_value { |q| q << "!" }
p s1, h1

s2 = +"b"
h2 = { "k" => s2, "j" => +"c" }
h2.each { |k, q| q << k }
p s2, h2

s3 = +"d"
h3 = {}
h3[:x] = s3
h3.each_pair { |k, q| q.concat("?") }
p s3, h3

s4 = +"e"
h4 = { k: s4 }
h4.values.each { |q| q << "#" }
p s4, h4

def bang(v) = (v << "!")
h5 = { a: +"f", b: +"g" }
h5.each_value { |q| bang(q) }
p h5

# a Hash literal iterated in place, directly and through a lambda that
# captures the value
s6 = +"h"
{ k: s6 }.each_value { |q| q << "!" }
p s6
s7 = +"i"
{ k: s7 }.each { |k, q| l = -> { q << "#" }; l.() }
p s7

h6 = { k: "lit" }
begin
  h6.each_value { |q| q << "x" }
rescue => e
  p e.class
end

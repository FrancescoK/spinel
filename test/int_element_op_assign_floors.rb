# `%=`, `/=` and `**=` on an Integer array element, hash value or attribute
# floor as Ruby's `%` and `/` do, and raise the power.
b = [-7, -7, 3, 5, 4]
b[0] %= 3
b[1] /= 2
b[2] **= 3
b[3] -= 9
b[4] <<= 2
p b
h = {"a" => -7, "b" => 9, "c" => 1}
h["a"] %= 3
h["b"] /= -2
h["b"] **= 2
h["c"] += 2
h["c"] *= 5
p h

class P
  attr_accessor :n
  def initialize; @n = -7; end
end
o = P.new
o.n %= 3
p o.n
o.n **= 3
p o.n
o.n /= -3
p o.n

require "strscan"
sc = StringScanner.new("abcdefghij")
sc.pos += 7
sc.pos %= 3
p sc.pos
sc.pos **= 3
p sc.rest

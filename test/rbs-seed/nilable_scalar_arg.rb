# An --rbs `Integer?` / `Float?` / `String?` PARAMETER must keep nil, even when
# the argument's nil-ness is only known at run time. A literal nil already
# lands on the slot's sentinel; this is the common case -- an element of a
# mixed array, a Hash miss, an untyped call -- where the argument is poly and
# the plain conversion answers the type's zero, which in these slots is an
# ordinary value. The argument-side sibling of #3412 (attribute) and #3458
# (return value). #3465.
# spinel: rbs-seed-check
class W
  def self.pi(n); n.nil? ? "nil" : "int #{n}"; end
  def self.pf(f); f.nil? ? "nil" : "flt #{f}"; end
  def self.ps(s); s.nil? ? "nil" : "str #{s}"; end
end

[1, nil].each   { |v| puts W.pi(v) }
[1.5, nil].each { |v| puts W.pf(v) }
["x", nil].each { |v| puts W.ps(v) }

# a Hash miss is the same shape
h = { "a" => 1 }
puts W.pi(h["a"])
puts W.pi(h["zz"])

# and a literal nil, which was already correct, must stay so
puts W.pi(nil)
puts W.pf(nil)
puts W.ps(nil)

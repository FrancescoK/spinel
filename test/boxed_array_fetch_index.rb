# spinel: int64 -- assumes a 64-bit Integer (a Bignum index needs it)
# fetch and values_at on a boxed Array take an index as fetch with a block
# does: anything that converts to an Integer, and nothing else. A Symbol, a
# String, true or a Float read element 0 or another wrong one.

def pick(n) = n > 0 ? {a: 1} : [10, "s", :z]

def report
  p yield
rescue TypeError, IndexError, RangeError => e
  puts "#{e.class}: #{e.message}"
end

h = pick(0)
report { h.fetch(true) }
report { h.fetch(:a) }
report { h.fetch("a") }
report { h.fetch([0]) }
report { h.fetch(nil) }
report { h.fetch(1.5) }
report { h.fetch(-1.5) }
report { h.fetch(:a, 9) }
report { h.fetch(7.5) }
report { h.fetch(7.5, :dflt) }

report { h.values_at(true) }
report { h.values_at(:a) }
report { h.values_at("a") }
report { h.values_at(0, nil) }
report { h.values_at(1.5, 2) }

# an index that is a call runs ahead of values_at and is read the same way
report { h.values_at([:a].first) }
report { h.values_at(["a"].first, 0) }

# a NaN, a far Float and a Bignum are past every index: RangeError
w = { "nan" => 0.0 / 0.0, "far" => 1e30, "big" => 2**70 }
report { h.fetch(w["nan"]) }
report { h.fetch(w["nan"], :dflt) }
report { h.fetch(w["far"]) }
report { h.fetch(w["big"]) }
report { h.values_at(w["nan"]) }
report { h.values_at(0, w["big"]) }

# the smallest Integer, here a Bignum, is an offset like any other: it is
# past the Array, and no error of conversion; one below it is
m = { "min" => -(2**63), "past" => -(2**63) - 1, "s" => "x" }
report { h.fetch(m["min"], :dflt) }
report { h.fetch(m["min"]) }
report { h.values_at(0, m["min"], 1) }
report { h.fetch(m["past"], :dflt) }

# out of a local the smallest Integer is nil to an int slot; on an empty
# Array it still reads past the end, as it did
def none(n) = n > 0 ? {a: 1} : [[], "s"][0]
e = none(0)
k = -9223372036854775807 - 1
report { e.fetch(k, :dflt) }

# an index object's to_int is the program's code and can shorten the Array:
# the index is tested against the length it leaves
class Shr
  def initialize(a) = (@a = a)
  def to_int
    @a.clear
    2
  end
end
class Pop2
  def initialize(a) = (@a = a)
  def to_int
    @a.pop
    @a.pop
    1
  end
end
x = [[10, "a", :b], 1][0]
report { x.fetch(Shr.new(x), "d") }
p x
y = [[10, "a", :b], 1][0]
report { y.fetch(Shr.new(y)) }
z = [[10, "a", :b], 1][0]
report { z.fetch(Pop2.new(z), "d") }
p z
v = [[10, "a", :b], 1][0]
report { v.fetch(Shr.new(v), 77) }
def text_of = yield
u = [[10, "a", :b], 1][0]
puts text_of { u.fetch(Shr.new(u), "d") }

# an Integer and a Range answer as before, and so does a Hash
p h.fetch(0)
p h.fetch(-1)
p h.fetch(5, :dflt)
report { h.fetch(5) }
p h.values_at(0, 2, 5)
p h.values_at(0..1)
g = pick(1)
p g.fetch(:a)
p g.values_at(:a, :b)
report { g.fetch(:b) }

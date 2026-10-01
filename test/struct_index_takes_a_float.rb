# Struct#[], #[]= and #dig take a Float offset as CRuby does: it is cut to the
# Integer it converts to; an out-of-range one names that offset in its error.
S = Struct.new(:a, :b)
s = S.new(10, 20)

def try(n) = (begin; p [n, yield]; rescue Exception => e; p [n, e.class, e.message[0, 70]]; end)

try(:half) { s[0.5] }
try(:neg_half) { s[-0.5] }
try(:one9) { s[1.9] }
try(:neg19) { s[-1.9] }
try(:whole) { s[1.0] }
try(:big) { s[5.5] }
try(:small) { s[-5.5] }
try(:dig) { s.dig(0.5) }
try(:dig_second) { s.dig(1.5) }
try(:dig_nested) { S.new(S.new(1, 2), 3).dig(0.5, 1) }
try(:dig_out) { s.dig(9.5) }
try(:set) { s[1.5] = 99; s.b }
try(:set_zero) { s[0.9] = 5; s.a }
try(:set_big) { s[5.5] = 1 }
try(:set_small) { s[-5.5] = 1 }
try(:values_at) { s.values_at(0.5, 1.9) }

f = 1.25
try(:var) { s[f] }
try(:var_set) { s[f] = 7; s.b }
g = [0.5, 1.5]
try(:elem) { s[g[1]] }

class Pt < Struct.new(:x, :y)
  def sum = self[0.5] + self[1.5]
end
try(:sub) { Pt.new(3, 4).sum }

D = Struct.new(:name, :n, keyword_init: true)
try(:kw) { D.new(name: "a", n: 2)[1.2] }

# a Float offset after the first key of a dig chain, and a store of another type
W = Struct.new(:a, :b)
w = W.new(S.new(1, 2), 3)
try(:dig_chain) { w.dig(0.5, 1.5) }
try(:dig_chain0) { w.dig(0, 1.5) }
try(:dig_chain_out) { w.dig(0, 2.5) }
try(:dig_array) { [S.new(5, 6)].dig(0, 1.5) }

R = Struct.new(:a, :b)
t = R.new(10, 20)
t[1.5] = 2.5
p t.b
R2 = Struct.new(:a, :b)
u = R2.new(10, 20)
u[0.5] = "str"
p u.a
R3 = Struct.new(:a, :b)
v = R3.new(10, 20)
v[-1.5] = :sym
p v.b
R4 = Struct.new(:a, :b)
x = R4.new(1, 2)
x[1.9] = [1]
p x.b

# a class with a `[]=` of its own keeps it for a Float offset
class Ov < Struct.new(:a, :b)
  def []=(k, v)
    (@log ||= []) << [k.class, v]
  end

  def log
    @log
  end
end
o = Ov.new(1, 2)
o[0.5] = 3
p o.log, o.a, o.b

# the ends of the Integer range: the fraction is cut, the offset is too large
try(:edge_hi) { s[2147483647.5] }
try(:edge_lo) { s[-2147483648.5] }
try(:values_edge) { s.values_at(2147483647.5) }

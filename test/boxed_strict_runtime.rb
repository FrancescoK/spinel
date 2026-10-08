B = [5, "s", :sym, nil, 1.9, {a: 1}, 1..2, -2, [1]]
def bx(i) = B[i]
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
class TH
  def to_hash = {z: 3}
end

r = [[10, 20, 30], "q"][0]
[7, 1, 2, 3, 4, 5, 6, 8].each { |i| t { r.values_at(*[bx(i)]) } }
t { [10, 20, 30].values_at(*[bx(4)]) }

h = [{x: 1}, 1][0]
[0, 1, 3, 5].each { |i| t { h.merge(bx(i)) } }
t { h.merge(5) }
t { h.merge({y: 2}, bx(0)) }
t { h.merge(TH.new) }
[0, 1, 3, 5].each { |i| t { {x: 1}.merge(bx(i)) } }

s = ["hello", 1][0]
t { s * 1.9 }
[4, 0, 1, 3, 2, 7, 5].each { |i| t { s * bx(i) } }
a = [[1, 2], 1][0]
[0, 1, 4, 3].each { |i| t { a * bx(i) } }
t { "ab" * bx(4) }
class TI
  def to_int = 3
end
class TA
  def hv = {y: 4}
  alias to_hash hv
end
class TM
  def hm = {w: 5}
  alias_method :to_hash, :hm
end
t { s * TI.new }
t { a * TI.new }
h = [{a: 1}, 1][0]
t { h.merge(TA.new) }
t { h.merge(TM.new) }
class TS
  def to_str = "-"
end
class TB
  def to_str = "+"
  def to_int = 2
end
t { a * TS.new }
t { a * TB.new }
t { s * TB.new }

# A block that leaves by a jump (`break`) hands its yield no value: the
# yield takes its type from the sites whose blocks answer, and where none
# does, a conditional around it keeps its other arm's type.

class Y
  attr_reader :b
  def m = (@b = block_given? ? yield : :none)
  def n; @b = yield; end
end
def pick = (block_given? ? yield : 2)
def pick2 = (block_given? ? yield : :none)
def pick3(x) = (x > 0 ? yield(x) : -1)

y = Y.new
p y.m { break :b }, y.b, y.m { 3 }, y.b
p y.n { break :c }, y.n { 4 }
p((pick { break :x }), (pick2 { break 4 }), (pick2 { 3 }), pick2)
p((pick3(1) { |v| break v * 5 }), (pick3(2) { |v| v + 1 }), (pick3(0) { |v| v }))
r = [1, 2].map { |i| pick2 { break i if i == 1; i * 10 } }
p r

# A block that ends in a jump but holds an earlier `next` with a value can
# still complete with that value, in the tail, in a local and in a
# conditional's arm.
def pk; yield; end
def vi(flag); pk { next 7 if flag; return 8 }; end
def vs(flag); pk { next :a if flag; return :r }; end
def vl(flag); x = pk { next 7 if flag; return 8 }; x + 1; end
def vt(flag); (flag ? pk { next 7 if flag; return 8 } : 0) + 1; end
p vi(true), vi(false), vs(true), vs(false)
p vl(true), vl(false), vt(true), vt(false)

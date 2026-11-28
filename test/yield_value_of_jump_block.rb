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

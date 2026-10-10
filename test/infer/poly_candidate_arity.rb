# A call on a receiver of unknown class reaches only the methods of its name
# that take its argument count; any other raises ArgumentError. Every
# `output` was bound from `hs[i].output(pick)`, and its untyped argument
# boxed the first parameter of Seq#output(col, shift), which only Integers
# ever reach.
class Seq
  def output(col, shift) = (col * 8) + shift
end

class History
  def output(sid) = sid * 4
end

class Empty
  def output(_sid) = 0
end

class Slots
  def output(a, b = 0, *rest) = a + b + rest.size
end

s = Seq.new
t = 0
1000.times { |i| t += s.output(i, 3) }
p t

hs = [History.new, Empty.new, Slots.new]
picks = [1, "2", 3]
p hs[0].output(picks[0])
p hs[1].output(picks[1])
p hs[2].output(picks[2])
p hs[2].output(*[1, 2, 3])

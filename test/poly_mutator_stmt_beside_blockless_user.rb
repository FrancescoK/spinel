# An in-place mutator with a block, as a statement on a boxed receiver,
# beside a class of the program's own whose method of the name takes no
# block: an Array takes the builtin's arm and changes in place, and the
# class's own method runs, ignoring the block.
class Shut
  def initialize = @calls = 0
  attr_reader :calls
  def map! = (@calls += 1; nil)
  def select! = (@calls += 1; nil)
  private def reject! = nil
end

def pick(a, i) = a[i]
m = pick([[1, 2, 3], Shut.new], 0)
m.map! { |e| e * 10 }
p m
s = pick([[1, 2, 3, 4], Shut.new], 0)
s.select! { |e| e.even? }
p s
r = pick([[1, 2, 3, 4], Shut.new], 0)
r.reject! { |e| e > 2 }
p r
sh = pick([[1], Shut.new], 1)
sh.map! { |e| e }
sh.select! { |e| e }
p sh.calls

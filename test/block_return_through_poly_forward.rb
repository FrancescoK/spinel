# A yielding method that hands its block on to the same method of boxed
# receivers (`@kids.each { |k| k.walk(&blk) }` over a mixed Array), and a
# caller whose block `return`s. The dispatch makes the block a real proc, but
# the caller was not given the proc-return frame the proc leaves through: the
# `return v` returned from the proc alone and the caller answered nil where
# CRuby answers the value. A forward to a boxed receiver is a block that does
# not stop at the forwarder, so the block is lifted and the caller has the frame.
class Tree
  def initialize(v, kids = []) = (@v = v; @kids = kids)

  def walk(&blk)
    return to_enum(:walk) unless block_given?
    yield @v
    @kids.each { |k| k.walk(&blk) }
    self
  end

  def find_v(t)
    walk { |v| return v if v == t }
    nil
  end

  def count_until(limit)
    seen = 0
    walk { |v| seen += 1; return seen if v >= limit }
    -seen
  end
end

t = Tree.new(1, [Tree.new(2), Tree.new(3, [Tree.new(4)])])
p t.walk.to_a
p t.walk { }.equal?(t)
p t.find_v(4), t.find_v(9)
p t.count_until(3), t.count_until(99)
p t.walk.select(&:even?)

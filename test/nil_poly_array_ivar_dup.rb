# An Array instance variable a write leaves nil answers dup and clone as nil
# does: nil (#9347). The slot holds a mixed Array or nothing.
class Q
  def initialize(f) = (@r = f ? [1, "a"] : nil)
  def d = @r.dup
  def c = @r.clone
end
p Q.new(false).d, Q.new(false).c
p Q.new(true).d, Q.new(true).c
class R
  def initialize(f) = (@r = f ? [[1], [2]] : nil)
  def d = @r.dup
end
p R.new(false).d, R.new(true).d

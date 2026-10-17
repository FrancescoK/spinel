# run-scale: 100000 100 | 100000 1600 | 1.5
# #9434: a shared handle handed on to a read-only parameter beside an
# object, an element read of a typed Array or an attr_reader's read was
# copied in full at every call. The bytes allocated must not grow with the
# calls.
class Node
  attr_reader :off
  def initialize(off) = @off = off
end
class Holder
  def initialize(len)
    @buf = "\0".b * len
    @buf.setbyte(0, 7)
    @node = Node.new(0)
    @w = [0, 1]
  end
  def self.at(s, i, node) = s.getbyte((i + node.off) % 64)
  def self.sum(s, i, node) = at(s, i, node)
  def self.at_idx(s, i, k) = s.getbyte((i + k) % 64)
  def self.sum_idx(s, i, w) = at_idx(s, i, w[0])
  def peek
    b = @buf
    b.getbyte(1)
  end
  def run(n)
    t = 0
    n.times { |i| t += Holder.sum(@buf, i, @node) + Holder.sum_idx(@buf, i, @w) }
    t
  end
end
p Holder.new(ARGV[0].to_i).run(ARGV[1].to_i)

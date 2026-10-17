# spinel: share
# A shared String handed on to a read-only method borrows its buffer when
# what travels beside it runs nothing (#9434): an object the callee only
# hands on, an element read of a typed Array, an attr_reader's read of a
# field. A reader a subclass overrides with a method is a call, and the
# String it travels beside keeps its copy. Every answer is CRuby's.
class Node
  attr_reader :off

  def initialize(off)
    @off = off
  end
end

class Loud < Node
  def off
    $log << "off"
    1
  end
end

class Buf
  def initialize
    @buf = +"abcdefgh"
    @buf << "ij"
    @node = Node.new(2)
    @loud = Loud.new(0)
    @w = [3, 1]
  end

  def self.obj(s, i, node) = s.getbyte(i % 10)
  def self.fwd_obj(s, i, node) = obj(s, i, node)
  def self.idx(s, i, k) = s.getbyte((i + k) % 10)
  def self.fwd_idx(s, i, w) = idx(s, i, w[0])
  def self.at(s, i, node) = s.getbyte((i + node.off) % 10)
  def self.fwd_attr(s, i, node) = at(s, i, node)

  def run
    b = @buf
    b << "k"
    [Buf.fwd_obj(@buf, 1, @node), Buf.fwd_idx(@buf, 1, @w), Buf.fwd_attr(@buf, 1, @node),
     Buf.fwd_attr(@buf, 1, @loud), @buf]
  end
end

$log = []
p Buf.new.run
p $log

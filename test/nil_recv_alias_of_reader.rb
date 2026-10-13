# A call on an object that may be nil, through an alias of an attr_reader,
# answers as nil does for the name it was written as: nil.to_a is [] and
# nil.to_s is "", and a name nil lacks raises NoMethodError naming it, not
# the reader the alias names. A #to_a of its own answers [] for nil too.
class Node
  def initialize(c) = (@children = c; @label = "node")
  attr_reader :children, :label
  alias to_a children
  alias to_s label
  alias kids children
end

class Box
  def initialize(v) = @v = v
  def to_a = @v
end

def arr(x) = x.to_a
def str(x) = x.to_s
def kids_of(x) = x.kids
def all(x) = [*x]

p arr(Node.new([:a, 1]))
p arr(nil)
p str(Node.new([]))
p str(nil)
p kids_of(Node.new([2]))
begin
  kids_of(nil)
rescue NoMethodError => e
  puts e.message
end
p all(Box.new([1]))
p all(nil)
p arr(Box.new([3]))

# Arguments a call evaluates ahead of itself -- each a fresh allocation the
# next argument's evaluation can collect -- are held in one rooted temp each
# and passed as that temp: a second rooted copy of the same pointer was a
# frame slot and a store on every call. Run under SPINEL_GC_STRESS=1 the
# values must survive the later arguments and the callee's own allocation.
class Node
  attr_reader :left, :right
  def initialize(left, right)
    @left = left
    @right = right
  end
end

class Leaf < Node
end

def make_tree(depth)
  return Leaf.new(nil, nil) if depth == 0
  d = depth - 1
  Node.new(make_tree(d), make_tree(d))
end

def check_tree(node)
  return 1 if node.left.nil?
  1 + check_tree(node.left) + check_tree(node.right)
end

# a subclass instance into a parameter of its parent's type
mixed = Node.new(Leaf.new(nil, nil), make_tree(2))
puts check_tree(mixed)
puts check_tree(make_tree(6))

class Pair
  attr_reader :a, :b
  def initialize(a, b)
    @a = a
    @b = b
  end
end

def join(x, y) = x + "|" + y

# fresh Strings, into a constructor and into a method
pr = Pair.new("ab" + "cd", "x" * 3)
puts pr.a, pr.b
puts join("p" + "q", "r" * 2)

# fresh Arrays and Hashes
def total(xs, h) = xs.sum + h.values.sum
puts total([1, 2, 3].map { |v| v * 2 }, { a: 1, b: 2 }.select { |_k, v| v > 0 })
q = Pair.new([1, 2].map { |v| v + 1 }, { k: "v" }.dup)
p q.a, q.b

# a mixed value
def show(v) = v.inspect
puts show([1, "s", :y].map { |v| v })

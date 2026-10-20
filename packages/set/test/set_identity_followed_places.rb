# Identity Sets that live in instance variables and a local, read only as
# a Set's receiver (also through a reader that answers one), beside many
# classes whose boxed values take include?, +, - and & with Strings and
# Integers, and plain Sets of Strings and Floats: only the calls on the
# identity Sets are checked, and their members are the program's objects.
require "set"

class Node
  attr_reader :name
  def initialize(name) = @name = name
end

class RedundantSelf
  def initialize
    @allowed = Set.new.compare_by_identity
  end

  def allow(node) = @allowed.add(node)
  def allowed?(node) = @allowed.include?(node)
end

class BlockArg
  def initialize
    @defs = Set.new.compare_by_identity
  end

  def see(node)
    return false if @defs.include?(node)

    @defs << node
    true
  end
end

class Force
  def scanned_nodes
    @scanned_nodes ||= Set.new.compare_by_identity
  end

  def scan(node)
    return :seen if scanned_nodes.include?(node)

    scanned_nodes << node
    :new
  end
end

class Words
  def initialize(ws) = @ws = ws
  def include?(w) = @ws.include?(w)
  def +(o) = Words.new(@ws + [o])
  def -(o) = Words.new(@ws - [o])
  def &(o) = @ws & o
end

class Range2
  def initialize(a, b) = (@a, @b = a, b)
  def include?(x) = x.is_a?(Integer) && @a <= x && x <= @b
end

a = Node.new("a")
b = Node.new("a")
rs = RedundantSelf.new
rs.allow(a)
p rs.allowed?(a), rs.allowed?(b)
ba = BlockArg.new
p ba.see(a), ba.see(a), ba.see(b)
f = Force.new
p f.scan(a), f.scan(a), f.scan(b)
local = Set[a].compare_by_identity
local << b
p local.size, local.include?(Node.new("a"))

def pick(xs, i) = xs[i]
things = [Words.new(%w[x y]), Range2.new(1, 5), Set["x", "z"], [1, 2], { "x" => 1 }]
p things.map { |t| t.include?("x") }
p pick(things, 1).include?(3), pick(things, 2).include?("z")
w = pick(things, 0)
p (w + "q").include?("q"), (w - "x").include?("x"), w & %w[y q]
plain = Set["a", "b"]
p plain.include?("a"), (plain | Set["c"]).size, (plain - Set["a"]).to_a
floats = Set[0.1, 0.2]
p floats.include?(0.1), floats.include?(0.3)

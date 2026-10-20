# An identity Set's alias answered as the value of an each block (the
# iterator drops it), and through methods whose last value it is, inside
# an if and a begin with a rescue, whose own callers drop it: the Set is
# followed there, so only the calls on it are checked, and a boxed
# include? with a String elsewhere compiles.
require "set"

class Node; end

class Force
  def scanned_nodes
    @scanned_nodes ||= Set.new.compare_by_identity
  end

  def scan
    [1, 2].each do |i|
      scanned_nodes << Node.new
    end
    scanned_nodes.size
  end
end

class Cop
  def initialize = @allowed = Set.new.compare_by_identity

  def allow_self(n)
    return unless n

    @allowed.add(n)
  end

  def on_op_asgn(n) = allow_self(n)
  def allowed?(n) = @allowed.include?(n)
end

class Dispatch
  def initialize(cop) = @cop = cop

  def dispatch_on_op_asgn(n)
    if @cop
      begin
        @cop.on_op_asgn(n)
      rescue StandardError => e
        p e
      end
    end
  end

  def walk(n)
    dispatch_on_op_asgn(n)
    nil
  end
end

def pick(a, i) = a[i]
p Force.new.scan
c = Cop.new
n = Node.new
Dispatch.new(c).walk(n)
p c.allowed?(n), c.allowed?(Node.new)
p pick([%w[a b], Set["a"]], 1).include?("a"), pick([%w[a b], Set["a"]], 0).include?("b")

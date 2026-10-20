# An identity Set's alias answered through a method's tail (`allow_self`,
# `on_op_asgn`) to a caller that calls it inside an if and a begin with a
# rescue, where that if is not the last statement of the caller: its value
# is dropped there. The Set is followed, so only the calls on it are
# checked, and a boxed include? with a String elsewhere compiles.
require "set"

class Node; end

class Cop
  def initialize = @allowed = Set.new.compare_by_identity

  def allow_self(n)
    return unless n

    @allowed.add(n)
  end

  def on_op_asgn(n) = allow_self(n)
  def allowed?(n) = @allowed.include?(n)
end

class Other
  def on_op_asgn(n) = n
end

class Dispatch
  def initialize(a, b) = (@cop_a = a; @cop_b = b)

  def dispatch_on_op_asgn(n)
    if @cop_a
      begin
        @cop_a.on_op_asgn(n)
      rescue StandardError => e
        p e
      end
    end
    if @cop_b
      begin
        @cop_b.on_op_asgn(n)
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
c = Cop.new
n = Node.new
Dispatch.new(c, Other.new).walk(n)
p c.allowed?(n), c.allowed?(Node.new)
p Set["a", "b"].include?(pick(["a", 1], 0))

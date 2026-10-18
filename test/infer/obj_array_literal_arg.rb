# An array literal of one class handed straight to a method or a
# constructor narrows the parameter, and the ivar it is stored in, to the
# unboxed pointer array, as the same literal held in a local first does
class Step
  def initialize(n) = @n = n
  def apply(x) = x + @n
end

class Holder
  def initialize(steps) = @steps = steps
  def run(x) = @steps.sum { |s| s.apply(x) }
end

def total(parts, x) = parts.sum { |s| s.apply(x) }

p Holder.new([Step.new(1), Step.new(2)]).run(10)
p total([Step.new(3)], 10)

# An array literal passed straight to a method or a constructor: of one
# class it narrows the parameter to the unboxed pointer array, while a
# literal mixing classes, nil or an Integer stays the boxed Array
class Step
  def initialize(n) = @n = n
  def apply(x) = x + @n
end

class Twice
  def apply(x) = x * 2
end

class Big < Step
  def apply(x) = x * 100
end

class Holder
  def initialize(steps) = @steps = steps
  def run(x) = @steps.sum { |s| s.apply(x) }
end

class Setter
  def set(steps) = @steps = steps
  def run(x) = @steps.map { |s| s.apply(x) }
end

class Mixed
  def initialize(items) = @items = items
  def run = @items.map { |s| s.nil? ? 0 : s.is_a?(Integer) ? s : s.apply(1) }
end

def total(parts, x) = parts.sum { |s| s.apply(x) }
def count(a) = a.size

p Holder.new([Step.new(1), Step.new(2)]).run(10)
p total([Step.new(3)], 10)
s = Setter.new
s.set([Step.new(5), Step.new(6)])
p s.run(10)
p Holder.new([Step.new(1), Twice.new]).run(10)
p Holder.new([Step.new(1), Big.new(2)]).run(10)
p Mixed.new([Step.new(1), nil]).run
p Mixed.new([Step.new(1), 7]).run
p count([Step.new(1), nil])
p count([Step.new(1), *[Step.new(2)]])

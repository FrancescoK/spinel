class Step
  def initialize(n) = @n = n
  def apply(x) = x + @n
end

class Holder
  def initialize(steps) = @steps = steps
  def run(x) = @steps.map { |step| step.apply(x) }
end

class Table
  def [](k) = k * 2
end

module Restore
  def self.apply(table, names)
    names.map { |name| table[name] }
  end
end

bang = proc { |s| s << "!" }
str = +"x"
bang.call(str)
p str
p Restore.apply(Table.new, %w[ab cd])
p Holder.new([Step.new(1), Step.new(2)]).run(10)

# `step.apply(2, by: [1, 2])` on a boxed element: a method with keywords takes
# only a call whose keywords it names and that passes every keyword it
# requires, so `Restore.apply(table, names:)` is not its callee and `table`
# keeps the Table its own caller passes.
class Step
  def initialize(n) = @n = n
  def apply(k, by:) = by.map { |x| x * k + @n }
end

class Scale
  def initialize(n) = @n = n
  def apply(k, by:) = by.map { |x| x * k * @n }
end

class Other
  def apply(k, names: []) = names.size + k
end

class Holder
  def initialize(steps) = @steps = steps
  def run = @steps.map { |step| step.apply(2, by: [1, 2]) }
end

class Table
  def [](k) = k * 2
end

module Restore
  def self.apply(table, names:)
    names.map { |name| table[name] }
  end
end

p Restore.apply(Table.new, names: [3, 4])
p Holder.new([Step.new(1), Scale.new(2)]).run
p [Other.new, Step.new(0)].map { |o| o.apply(1, by: [5]) rescue o.apply(1) }

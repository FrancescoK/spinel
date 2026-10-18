# `step.apply(names: [1, 2])` on a boxed element: a keyword hash counts as a
# positional argument only for a method that declares no keywords, so
# `Restore.apply(table, names:)` is not its callee and its `names` keeps the
# String Array its own caller passes.
class Step
  def initialize(n) = @n = n
  def apply(names:) = names.map { |x| x + @n }
end

class Scale
  def initialize(n) = @n = n
  def apply(names:) = names.map { |x| x * @n }
end

class Holder
  def initialize(steps) = @steps = steps
  def run = @steps.map { |step| step.apply(names: [1, 2]) }
end

class Table
  def [](k) = k * 2
end

module Restore
  def self.apply(table, names:)
    names.map { |name| table[name] }
  end
end

bang = proc { |s| s << "!" }
str = +"x"
bang.call(str)
p str
p Restore.apply(Table.new, names: %w[ab cd])
p Holder.new([Step.new(1), Scale.new(2)]).run

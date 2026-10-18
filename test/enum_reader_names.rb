# A reader named like an Enumerable method (count, first, min, select, map,
# detect, find, sort, size, ...) answers its ivar on a class that includes
# Enumerable, read through an explicit receiver, self. and the implicit self,
# in value and statement position; Enumerable's own methods keep working on a
# class that has no such reader.
class Items
  include Enumerable
  attr_reader :count, :first, :min, :max, :sum, :to_a, :entries, :select, :map, :detect, :find, :sort, :size
  def initialize
    @count = 1; @first = 2; @min = 3; @max = 4; @sum = 5; @to_a = 6; @entries = 7
    @select = 8; @map = 9; @detect = 10; @find = 11; @sort = 12; @size = 13
  end
  def each; yield 3; yield 1; end
  def inner
    [count, first, min, max, sum, to_a, entries, select, map, detect, find, sort, size]
  end
  def inner_self
    [self.count, self.first, self.min, self.max, self.sum, self.to_a, self.entries, self.select, self.map, self.detect, self.find, self.sort, self.size]
  end
end
i = Items.new
p [i.count, i.first, i.min, i.max, i.sum, i.to_a, i.entries, i.select, i.map, i.detect, i.find, i.sort, i.size]
p i.inner
p i.inner_self
x = i.count + i.first
p x
i.count
puts i.min.to_s
p i.reduce(:+)
p i.minmax
p i.sort_by { |v| v }

class Plain
  include Enumerable
  def each; yield 3; yield 1; end
end
q = Plain.new
p [q.count, q.first, q.min, q.max, q.sum, q.to_a, q.entries, q.sort]
p q.select { |v| v > 1 }
p q.map { |v| v * 2 }
p q.detect { |v| v < 2 }
p q.find { |v| v < 2 }
p q.include?(3)

# The block forms of Enumerable methods whose names are readers of the class:
# a reader takes no block and no argument, and the rest answer Enumerable's.
class Items
  include Enumerable
  attr_reader :count, :select, :map, :detect, :first, :sort, :min
  def initialize; @count = 1; @select = 8; @map = 9; @detect = 10; @first = 2; @sort = 12; @min = 3; end
  def each; yield 3; yield 1; end
  def blk_inner; [count { |v| v > 1 }, select { |v| v }, map { |v| v }]; end
end
i = Items.new
p i.count { |v| v > 1 }
p i.select { |v| v > 1 }
p i.map { |v| v * 2 }
p i.detect { |v| v < 2 }
p i.sort { |a, b| b <=> a }
p i.min { |a, b| b <=> a }
p i.blk_inner
begin
  p i.count(3)
rescue ArgumentError => e
  puts "AE #{e.message}"
end
begin
  p i.first(1)
rescue ArgumentError => e
  puts "AE #{e.message}"
end
begin
  p i.min(1)
rescue ArgumentError => e
  puts "AE #{e.message}"
end

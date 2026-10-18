# A reader of one class named like an Enumerable method (map, select, sort_by,
# find) leaves the same methods of an Array, whose stored Enumerator is later
# driven by each, as they were.
class X
  attr_reader :map, :select, :sort_by, :find
  def initialize; @map = 1; @select = 2; @sort_by = 3; @find = 4; end
end
e = [1, 2, 3].map
r = e.each { |v| v * 10 }
p r
s = [1, 2, 3].select
p s.each { |v| v.odd? }
t = %w[bb a ccc].sort_by
p t.each { |w| w.size }
f = [1, 2, 3].find
p f.each { |v| v > 1 }
h = {a: 1, b: 2}.map
p h.each { |k, v| [k, v * 2] }
x = X.new
p [x.map, x.select, x.sort_by, x.find]

class Level
  attr_reader :map
  def initialize; @map = [[0]]; end
end
lv = [1, 2, 3].map
p lv.each { |v| v * 10 }
p Level.new.map

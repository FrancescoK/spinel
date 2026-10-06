# An Array subclass instance held where a value of any class can be (#7449):
# boxed, it is still its Array to the runtime -- flatten, a splat, a
# destructuring, puts, ==, a Hash key -- and still its class to class,
# is_a?, instance_of?, case/when and the dispatch of its own methods. A
# method its class leaves to Array (push, size, map, include?) reaches
# Array's through the same dispatch.
class Row < Array
  def initialize(cells, label)
    super(cells)
    @label = label
  end
  attr_reader :label

  def describe = "#{label}: #{join(",")}"
end

class Grid < Array
  def rows_described = map(&:describe)
end

def kind(x)
  case x
  when Row then "row #{x.label}"
  when Array then "array of #{x.size}"
  when Integer then "int"
  else "other"
  end
end

r1 = Row.new([1, 2], "a")
r2 = Row.new([3], "b")
items = [r1, [9, 8, 7], 5, "s"]
items.each { |x| puts kind(x) }
x = items[0]
p x, x.class, x.is_a?(Row), x.is_a?(Array), x.instance_of?(Array), x.instance_of?(Row)
p x.describe, x.label, x.size, x.sum
p items[1].class, items[1].instance_of?(Array)
p items.flatten, [r1, [r2]].flatten.sum

grid = Grid.new([r1, r2])
p grid.rows_described, grid.size, grid.first.label, grid.class
grid.each { |row| p [row.label, row.class] }

h = { first: r1, second: r2 }
p h[:first].label, h.values.map(&:label), h

a, b = r1
p [a, b]
def splat_count(*args) = args.size
p splat_count(*r1), splat_count(r1), [*r1, *r2]
for v in r2
  p v
end
puts r1
p r1 == [1, 2], [1, 2] == items[0], items.include?([3]), items.index([1, 2])
p Array(r1).equal?(r1), Array(r1).class

class Nums < Array
  def total = sum
end
class Tags < Array
end
x = [Nums[1, 2], "s"][ARGV.size]
p x.total, x.push(4).total, x.size, x.first, x.map { |e| e * 2 }
y = [Tags[1, "a"], 3][ARGV.size]
p y.push(5).size, y.class, y.include?("a")
z = [Nums[7], Tags[8]][ARGV.size]
p z.size, z.push(1).class, z.total

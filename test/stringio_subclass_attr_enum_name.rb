# An attr_reader or attr_accessor named like an Enumerable method answers its
# ivar, not Enumerable's walk, on a StringIO subclass (which has the walk
# through StringIO#each) and on a class that includes Enumerable. Both the
# explicit and the implicit self receiver, in statement and value position.
require "stringio"

class Sub < StringIO
  attr_reader :count, :first, :min, :tally, :minmax, :chain
  attr_accessor :map, :sum
  attr_writer :string
  def initialize
    super("b\na\n")
    @count = 7
    @first = 8
    @min = 9
    @tally = 10
    @minmax = 11
    @chain = 12
    @map = 14
    @sum = 15
  end
  def implicit = [count, first, min, tally, minmax, chain, map, sum]
  def explicit = [self.count, self.first, self.min, self.tally, self.minmax, self.chain, self.map, self.sum]
  def peek = @string
end

s = Sub.new
p [s.count, s.first, s.min, s.tally, s.minmax, s.chain, s.map, s.sum]
p s.implicit
p s.explicit
x = s.count
y = s.minmax
p x + y
puts s.min
s.count
s.map = 21
s.sum += 1
p s.map, s.sum
s.string = "set"
p s.peek, s.string
p s.read
p s.lineno

class Items
  include Enumerable
  attr_reader :count, :first, :sort, :to_a, :find_all
  def initialize
    @count = 1
    @first = 2
    @sort = 3
    @to_a = 4
    @find_all = 6
  end
  def each
    yield 30
    yield 20
  end
  def implicit = [count, first, sort, to_a, find_all]
end

i = Items.new
p [i.count, i.first, i.sort, i.to_a, i.find_all]
p i.implicit
p i.min
p i.select { |v| v > 25 }

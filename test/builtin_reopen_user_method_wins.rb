# A program's own method on a builtin class answers the call, where a
# fold or a rewrite by the name used to answer the builtin's result.

# Enumerator#sum, typed receivers
class Enumerator
  def sum = :enum_sum
  def mine = :mine
end
e = 3.times
p e.sum
p [1, 2].each.sum
p [1, 2].map.sum
p 3.times.count
p 3.times.mine
p [1, 2].each.to_a

# names the builtin Enumerator answers itself, typed and through a local
class Enumerator
  def size = :enum_size
  def next = :enum_next
  def map = :enum_map
end
p e.size, e.next, [1, 2].each.size
p(e.map { |x| x }, 3.times.map { |x| x })

# Array.new defined by the program
class Array
  def self.new(*) = [:mine]
end
p Array.new.size, Array.new.empty?

# each_char.with_index on the program's own class
class Tape
  def initialize(s) = @s = s
  def each_char
    return to_enum(:each_char) unless block_given?
    @s.each_char { |c| yield c.upcase }
  end
end
t = Tape.new("abc")
p(t.each_char.with_index { |c, i| break i if c == "B" })
p("xyz".each_char.with_index { |c, i| break i if c == "y" })
p("hey".each_char.with_index { |c, i| })

# an alias in the Enumerator reopen calls the method it names
class Enumerator
  def mine2 = __method__
  alias other mine2
end
p 3.times.other, [1].each.send(:mine2)

# the names the builtin walks itself through #next, and the folds that
# take a block
class Enumerator
  def take_while = :enum_take_while
  def find(*) = :enum_find
  def find_index = :enum_find_index
  def include?(x) = :enum_include
  def inject(*) = :enum_inject
  def tally = :enum_tally
end
p([1, 2].each.take_while { |v| v < 2 }, [1, 2].each.find { |v| v > 1 })
p([1, 2].each.find_index { |v| v > 1 }, [1, 2].each.include?(2))
p([1, 2].each.inject { |s, v| s + v }, [1, 2].each.tally, 3.times.tally)
p([1, 2].each.detect { |v| v > 1 }, [1, 2].each.member?(2))

# a call written as detect or collect_concat does not reach a program's
# find or flat_map: CRuby defines each name as its own method
class Array
  def find(*) = :array_find
  def flat_map(*) = :array_flat_map
end
p([1, 2].detect { |v| v > 1 }, [1, 2].collect_concat { |v| [v] })
p([1, 2].find { |v| v > 1 }, [1, 2].flat_map { |v| [v] })

# self in an Enumerator reopen is the Enumerator, and a bare call is its own
class Enumerator
  def self_size = self.size
  def heads = [self.next, peek]
  def doubled = map { |x| x * 2 }
  def own_class = self.class
end
e2 = [1, 2, 3].each
p e2.self_size, e2.heads, e2.doubled, e2.own_class, 3.times.doubled

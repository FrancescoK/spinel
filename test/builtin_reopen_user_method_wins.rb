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

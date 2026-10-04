# A method added to a builtin class that takes an optional &block gets the
# call's block, or nil, as a method of a user class does (#7200).
class String
  def each_char_twice(&block)
    block ? chars.each { |c| 2.times { block.call(c) } } : chars.each
  end
end

class Integer
  def times_each(&blk)
    blk ? blk.call(self) : :none
  end
end

"ab".each_char_twice { |c| print c }
puts
e = "xy".each_char_twice
p e.to_a
p 3.times_each { |n| n * 2 }
p 3.times_each

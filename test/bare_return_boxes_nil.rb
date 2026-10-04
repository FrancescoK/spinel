# A bare `return` from a method that otherwise answers an Integer or Float is
# nil; passing the result where a parameter is boxed has to stay nil.

def size(flag)
  return unless flag
  128
end

def ratio(flag)
  return unless flag
  1.5
end

class Box
  def depth(flag)
    return if !flag
    7
  end

  def self.width(flag)
    [1, 2].each { |x| return if x > 1 && !flag }
    9
  end
end

def show(value) = value ? "got #{value}" : "nil"

puts show(size(false))
puts show(size(true))
puts show(ratio(false))
puts show(ratio(true))
puts show(Box.new.depth(false))
puts show(Box.new.depth(true))
puts show(Box.width(false))
puts show(Box.width(true))
held = size(false)
puts show(held)
puts held.nil?
p [size(false), ratio(false)]
puts show([nil, :sym].first)

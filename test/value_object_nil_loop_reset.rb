# A local assigned inside a block loop from a method that returns the object
# on some paths and (implicit) nil on others: the local is reset at each
# iteration, and the nil is the one `&.` tests for (#3267). Such a class
# keeps its pointer layout, whose NULL is the nil (the nil fact, #7444).
class Flag
  def initialize(bool) = @bool = bool
  def bool? = @bool
end

def find_flag(name)
  return Flag.new(true) if name == "-q"
  return Flag.new(false) if name == "-n"
end

def check(argument)
  (1...argument.length).each do |idx|
    flag = find_flag("-#{argument[idx]}")
    return false unless flag&.bool?
  end
  true
end

puts check("-qn")
puts check("-qq")

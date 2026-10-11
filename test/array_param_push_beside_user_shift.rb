# A push through an Array parameter, in a program that also defines a `<<`
# of its own, is the Array's push.
class Log
  def initialize = @lines = []

  def <<(line)
    @lines.push(line)
    self
  end

  def size = @lines.size
end

def add(list, x)
  list << x
end

nums = [1, 2]
add nums, "three"
p nums

words = ["a"]
add words, :b
p words

def add_two(list, x, y)
  list << x
  list << y
end

mixed = [1.5]
add_two mixed, 2, "c"
p mixed

log = Log.new
log << "hi" << "there"
p log.size

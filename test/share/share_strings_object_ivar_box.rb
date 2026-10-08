# A boxed ivar slot already carries its String handle through Object's read.
class Object
  def stored = @stored
end
class BoxedText
  def initialize(s) = (@stored = s)
  def clear = (@stored = false)
  def peek = @stored
end
s = +"text"
a = BoxedText.new(s)
r = a.stored
r << "!"
p r, s, a.peek
a.clear
p a.stored

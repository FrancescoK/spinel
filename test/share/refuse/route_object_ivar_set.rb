# The boxed reflective setter cannot store into a shared String handle slot.
class Object
  def change(v) = (@text = v)
end
class MutableText
  def initialize = (@text = +"old")
  def append = (@text << "!")
  def peek = @text
end
s = +"new"
a = MutableText.new
p a.change(s)
s << "?"
a.append
p a.peek, s

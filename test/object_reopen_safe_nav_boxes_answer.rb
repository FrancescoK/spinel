# A method the program adds to Object, called through `&.` on a receiver that
# may be nil: the call's slot is poly (it holds the nil), so the method's
# String, Integer or Float answer is boxed into it.
class Object
  def tag = "<#{self.class}>"
  def num = 42
  def fl = 1.5
  def me = self
end

class Foo; end

x = (rand < 2 ? "s" : nil)
p x&.tag
z = (rand > 2 ? "s" : nil)
p z&.tag
i = (rand < 2 ? 5 : nil)
p i&.num, i&.fl, i&.me
f = (rand < 2 ? Foo.new : nil)
p f&.tag, f&.num
a = (rand < 2 ? [1] : nil)
p a&.tag
v = x&.tag
p v.class, v.length
p "q".tag, 3.num + 1

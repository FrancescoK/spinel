# A constructor selected at run time accepts a String read for its shared
# parameter. Both instances keep the same handle across later writes.
class SharedText
  def initialize(count = 1, text)
    @count = count
    @text = text
  end
  def at(i) = @text.getbyte(i)
  def count = @count
end

class StringMutator
  def initialize(text) = @text = text
  def poke(i, value) = @text.setbyte(i, value)
end

def class_value(k) = k

s = +"abcd"
a = SharedText.new(2, s)
m = StringMutator.new(s)
m.poke(1, 90)
b = class_value(SharedText).new(3, s)
p [a.at(1), b.at(1), a.count, b.count]
m.poke(2, 89)
p [a.at(2), b.at(2)]

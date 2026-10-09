# An Enumerator over an assignment's value, where the writer changes the String
# it was handed: the Enumerator would keep a copy of the bytes it was made
# from, and the String changes again before it is read.
class K
  attr_reader :a
  def initialize = (@a = +"init")
  def a=(v)
    @a = v
    v << "w"
  end
end
o = K.new
s = +"ab"
e = (o.a = s).each_char.with_index
s << "c"
p e.to_a
p 1

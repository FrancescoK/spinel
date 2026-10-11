# An Enumerator over an assignment's value, where the writer changes the String
# it was handed: the Enumerator holds that String and reads it when it is
# walked, after it changes again.
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

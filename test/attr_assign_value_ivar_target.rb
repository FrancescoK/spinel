# The value of an attribute assignment kept in an instance variable of a
# method's object and appended to, in the default build and with
# --share-strings: the value is the String the writer stored.
class Acc
  attr_accessor :a
  def initialize = (@a = +"x")
  def set(o)
    @b = (o.a = +"lit")
    @b << "!"
    @b
  end
end
S = Struct.new(:a)
class KeepS
  def set(o)
    @b = (o.a = +"s")
    @b << "?"
    @b
  end
end

o = Acc.new
t = o.a
t << "?"
p Acc.new.set(o), o.a

st = S.new(+"x")
tt = st.a
tt << "?"
p KeepS.new.set(st), st.a

# String#prepend takes a boxed argument as the String it holds, as
# String#replace beside it does: here `v.to_str`, where v is a String or a
# wrapper. The boxed value went where the String was expected, and the C
# did not compile. pines' SafeBuffer shim prepends this way.
class Buf
  def initialize(s) = @str = String.new(s)
  def to_str = @str
  def prepend(v)
    @str.prepend(v.to_str)
    self
  end
  def insert(i, v)
    @str.insert(i, v.to_str)
    self
  end
  def to_s = @str
end
b = Buf.new("world")
b.prepend("hello ")
b.prepend(Buf.new(">"))
b.insert(1, Buf.new("~"))
p b.to_s

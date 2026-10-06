# `yield` answers the block's value, here the caller's s, so @a is s. @a
# held a copy and missed the append: refused, not compiled wrong.
class K
  def set = (@a = yield)
  def a = @a
end
o = K.new
s = +"abc"
o.set { s }
s << "!"
p o.a

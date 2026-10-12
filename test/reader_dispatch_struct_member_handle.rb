# A reader dispatched on a receiver that can hold a Struct, whose member is
# a plain String, and classes whose fields are Strings changed in place: the
# member's arm wraps its String as the others' fields are (the C did not
# build in either build).
class C
  attr_accessor :a
end
S = Struct.new(:a)
class W
  def a = @a
  def a=(v)
    @a = v
  end
end
o = C.new
s = +"ab"
o.a = s
so = S.new(+"x")
w = W.new
w.a = s
w.a.replace("qq")
w = [so, o].first
p w.a
w.a << "!"
p so.a, w.a
w = [o, so].last
w.a.replace("zz")
p so.a

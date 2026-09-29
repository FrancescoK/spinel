# A memoizing reader (`def s = (@s ||= +"")`) hands out the ivar's own
# String, so appending to what it returns changes the ivar. It returned a
# copy, and the append was lost.

class O
  def s = (@s ||= +"")
end
o = O.new
o.s << "q"
p o.s

class A
  def s
    @s ||= +"a"
  end
end
a = A.new
a.s << "q"
a.s.concat("r")
p a.s
p a.s.equal?(a.s)

class B
  def initialize; @n = 0; end
  def s = @s ||= +""
end
b = B.new
b.s << "x"
x = b.s
x << "y"
p b.s, x

class C < A
end
c = C.new
c.s << "c"
p c.s

arr = [A.new]
arr[0].s << "z"
p arr[0].s

class E
  def initialize(pre) = (@pre = pre)
  def s = (@s ||= @pre.dup)
end
e = E.new("p")
e.s << "1"
p e.s

# An ivar written from a parameter (`@v = x`) names the caller's String, so
# handing the ivar to a method that appends to its parameter -- through
# super, a plain call, or a top-level method -- appends to the caller's
# String. The ivar's slot was lent to the callee instead, and the appends
# went into the ivar alone.
class B
  def initialize(s) = (s << "!")
end

class C < B
  def initialize(x)
    @v = x
    super(@v)
  end
end
s1 = +"a"
C.new(s1)
p s1

class D
  def add(s) = (s << "?")
  def go(x)
    @v = x
    add(@v)
    t = +"t"
    add(t)
    p t
    @v = +"own"
    add(@v)
    p @v
  end
end
s2 = +"b"
D.new.go(s2)
p s2

class E
  def initialize(a, b)
    a << "1"
    b << "2"
  end
end
class F < E
  def initialize(x, y)
    @p = x
    @q = y
    super(@p, @q)
  end
end
s3 = +"c"
s4 = +"d"
F.new(s3, s4)
p s3, s4

class G
  def add(s) = (s << "!")
  def keep(x) = (@w = x)
  def go = add(@w)
end
s5 = +"e"
g = G.new
g.keep(s5)
g.go
g.go
p s5

def tl_add(s) = (s << "#")
def tl_go(x)
  @tv = x
  tl_add(@tv)
end
s6 = +"f"
tl_go(s6)
p s6

begin
  D.new.go("lit")
rescue => e
  p e.class
end

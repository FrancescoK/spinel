# A mutation through a receiver-less reader call (`buf << x` for
# `self.buf << x`) lands in the ivar's own String, not a copy.

class B
  def buf; @buf ||= +""; end
  def add(x); buf << x; end
  def add_each(xs); xs.each { |x| buf.concat(x) }; end
end
b = B.new
b.add("hi")
b.add("yo")
b.add_each(["!", "?"])
p b.buf

class E
  attr_reader :s
  def initialize; @s = +""; end
  def add(x); s << x; end
end
e = E.new
e.add("a")
e.add("b")
p e.s

class R
  def s; @s ||= +"x"; end
  def up; s.upcase!; s.insert(0, ">"); end
end
r = R.new
r.up
p r.s

module Buf
  def mbuf; @mbuf ||= +""; end
end
class P
  include Buf
  attr_accessor :name
  def initialize; @name = +"n"; end
  def add; mbuf << "m"; name << "!"; end
end
class Q < P
  def more; mbuf << "q"; name << "?"; end
end
q = Q.new
q.add
q.more
p q.mbuf
p q.name

class D
  def arr; @arr ||= []; end
  def add(x); arr << x; end
end
d = D.new
d.add(1)
d.add(2)
p d.arr

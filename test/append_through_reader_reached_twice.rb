# An append through a reader chain reaches the stored String when a method
# on it is first reached at the end of a long chain and then again from
# nearer the top: the second visit follows what the first was cut off from.

class N
  def initialize = @vals = [+"n"]
  def n = @vals[0]
  def vals = @vals
end

class M
  def initialize(n) = @n = n
  def m = @n.n
end

class C
  def initialize(m) = @m = m
  def k = @m.m
end

class B
  def initialize(c) = @c = c
  def h = @c.k
end

class A
  def initialize(b) = @b = b
  def g = @b.h
end

class P1
  def initialize(a) = @a = a
  def f = @a.g
end

class P2
  def initialize(m) = @m = m
  def f = @m.m
end

store = N.new
m = M.new(store)
long = P1.new(A.new(B.new(C.new(m))))
short = P2.new(m)
[long, short].each { |x| x.f << "!" }
p store.vals

class J
  def to_str(sep = ",") = "-#{sep}-"
end
p [1, 2] * J.new

class JI
  def to_str(sep = "+") = sep
  def to_int = 3
end
p [1, 2] * JI.new

class N
  def to_int(base = 2) = base
end
p "ab" * N.new
p [7] * N.new

class H
  def initialize(n) = (@n = n)
  def to_hash(opt = nil) = { b: @n }
end
h = { a: 1 }
h.merge!(H.new(2))
p h
p({ a: 1 }.merge(H.new(3)))

class D
  def initialize(f) = (@f = f)
  def to_hash(opt = nil) = @f ? { "s" => 2 } : { "x" => 1 }
end
s = { "a" => 1 }
s.merge!(D.new(true))
p s
t = { "a" => 1 }
t.update(D.new(false), { "z" => 9 }, D.new(true))
p t

class V
  def to_hash(o = 5) = { v: o }
end
k = { a: 1 }
k.merge!(V.new)
p k

class SK
  def initialize(f) = (@f = f)
  def to_hash = @f ? { "s" => 2 } : { "x" => 1 }
end
m = { "a" => 1 }
m.merge!(SK.new(true), SK.new(false))
p m
GC.start
p m.size

# spinel: gc-minor
# An explicit writer whose String nothing changes in place, or sees through a
# handle, keeps its plain pointer: the value of its assignment is that String
# all the same, so freezing it through unary plus, a conditional, a block, a
# method or `itself` freezes the one String, and an Enumerator over it reads it.

# en_lazy_W
class C0
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v
  end
end
o0 = C0.new
s0 = +"abc"
l0 = (o0.a = s0).each_char.lazy.map(&:upcase)
s0 << "d"
p l0.to_a

# en_lazy_W42
class C1
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v
    42
  end
end
o1 = C1.new
s1 = +"abc"
l1 = (o1.a = s1).each_char.lazy.map(&:upcase)
s1 << "d"
p l1.to_a

# en_lazy_Wdup
class C2
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v.dup
    self
  end
end
o2 = C2.new
s2 = +"abc"
l2 = (o2.a = s2).each_char.lazy.map(&:upcase)
s2 << "d"
p l2.to_a

# rk_each_char_next_W
class C3
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v
  end
end
o3 = C3.new
s3 = +"ab"
e3 = (o3.a = s3).each_char
p e3.next
s3.replace("zz")
p e3.next

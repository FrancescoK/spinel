# Two methods whose C names were one: a method is sp_<Class>_<name>, a class
# method sp_<Class>_s_<name>, and `?` spells `_p`, so A#B_c and A_B#c were
# both sp_A_B_c, A#s_make and A.make both sp_A_s_make, and A#a? and A#a_p
# both sp_A_a_p -- "conflicting types" and the program did not compile. The
# later of the two takes another name; calls reach each from its own class,
# from a subclass, from inside the class, and through a receiver that is
# either class. A_B#c__2 then meets the renamed c, which is renamed again.
class A
  def B_c = "A#B_c"
  def s_make = "A#s_make"
  def self.make = "A.make"
  def a? = true
  def a_p = "A#a_p"
  def b! = "A#b!"
  def b_bang = "A#b_bang"
  def x=(v)
    @x = v
  end
  def x_set(v) = "A#x_set(#{v})"
  def x = @x
  def all = [B_c(), s_make, a?, a_p, b!, b_bang, x_set(1)]
  def tag = "a"
end
class A_B
  def c__2 = "A_B#c__2"
  def c = "A_B#c"
  def tag = "a_b"
end
class Sub < A
  def c = "Sub#c"
end

a = A.new
a.x = 3
p a.all, a.x, A.make
p A_B.new.c, A_B.new.c__2
s = Sub.new
p s.B_c, s.a_p, s.c
[A.new, A_B.new].each { |o| p o.tag }

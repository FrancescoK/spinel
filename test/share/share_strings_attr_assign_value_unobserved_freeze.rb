# spinel: gc-minor
# An explicit writer whose String nothing changes in place, or sees through a
# handle, keeps its plain pointer: the value of its assignment is that String
# all the same, so freezing it through unary plus, a conditional, a block, a
# method or `itself` freezes the one String, and an Enumerator over it reads it.

# fzc_plus_freeze_W42
class C0
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v
    42
  end
end
o0 = C0.new
s0 = +"s0"
r0 = (+(o0.a = s0)).freeze
p r0.frozen?, s0.frozen?, r0.equal?(s0)

# fzc_plus_freeze_Wdup
class C1
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v.dup
    self
  end
end
o1 = C1.new
s1 = +"s1"
r1 = (+(o1.a = s1)).freeze
p r1.frozen?, s1.frozen?, r1.equal?(s1)

# fzc_freeze_in_if_W42
class C2
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v
    42
  end
end
o2 = C2.new
s2 = +"s2"
r2 = (true ? (o2.a = s2) : nil).freeze
p r2.frozen?, s2.frozen?

# fzc_freeze_in_if_Wdup
class C3
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v.dup
    self
  end
end
o3 = C3.new
s3 = +"s3"
r3 = (true ? (o3.a = s3) : nil).freeze
p r3.frozen?, s3.frozen?

# fzc_then_freeze_W42
class C4
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v
    42
  end
end
o4 = C4.new
s4 = +"s4"
r4 = (o4.a = s4).then { _1.freeze }
p r4.frozen?, s4.frozen?, r4.equal?(s4)

# fzc_then_freeze_Wdup
class C5
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v.dup
    self
  end
end
o5 = C5.new
s5 = +"s5"
r5 = (o5.a = s5).then { _1.freeze }
p r5.frozen?, s5.frozen?, r5.equal?(s5)

# fzc_user_freeze_W42
class C6
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v
    42
  end
end
o6 = C6.new
def fr6(x6) = x6.freeze
s6 = +"s6"
r6 = fr6(o6.a = s6)
p r6.frozen?, s6.frozen?, r6.equal?(s6)

# fzc_user_freeze_Wdup
class C7
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v.dup
    self
  end
end
o7 = C7.new
def fr7(x7) = x7.freeze
s7 = +"s7"
r7 = fr7(o7.a = s7)
p r7.frozen?, s7.frozen?, r7.equal?(s7)

# fzc_itself_freeze_W42
class C8
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v
    42
  end
end
o8 = C8.new
s8 = +"s8"
r8 = (o8.a = s8).itself.freeze
p r8.frozen?, s8.frozen?, r8.equal?(s8)

# fzc_tap_freeze_Wdup
class C9
  def initialize; @a = +"init"; end
  def a; @a; end
  def a=(v)
    @a = v.dup
    self
  end
end
o9 = C9.new
s9 = +"s9"
r9 = (o9.a = s9).tap(&:freeze)
p r9.frozen?, s9.frozen?

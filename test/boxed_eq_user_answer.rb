# `a == b` on a boxed receiver answers what the receiver's own == answers,
# which a program's == may give as any value (here a Symbol or nil). The
# runtime equality reduced it to true or false. Where such a call was
# typed boxed, a dynamic send's == arm (activesupport's Object#try) also
# put that raw bool in a boxed slot, and the C did not compile.
class Q
  def ==(o) = o == 1 ? :yes : nil
end
def eq(a, b)
  r = (a == b)
  r
end
p eq(1, 1)
p eq("a", "b")
p eq(Q.new, 1)
p eq(Q.new, 2)
def snd(o, *args) = o.public_send(*args)
p snd(Q.new, :==, 1)
p snd(3, :==, 3)

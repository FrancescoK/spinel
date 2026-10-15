# Flag-only. Kernel#String answers what its argument's #to_str, or with none
# its #to_s, answers, as it is: when that is the String the object holds
# (an ivar read, `+@n` of an unfrozen ivar, `@n.itself`, `@n.then { |x| x }`),
# the call is that String, not a new one. Appending to it, keeping it in a
# variable and changing that, or passing it through a method, shows in the
# String the object holds.
class Plus
  def initialize(n) = @n = n
  def to_str = +@n
end
class Itself
  def initialize(n) = @n = n
  def to_s = @n.itself
end
class Thens
  def initialize(n) = @n = n
  def to_str = @n.then { |x| x }
end
class Plain
  def initialize(n) = @n = n
  def to_str = @n
end
def conv(o) = String(o)
c = +"c"
String(Plus.new(c)) << "?"
p c
x = String(Itself.new(c))
x << "!"
p c, x
String(Thens.new(c)) << "#"
p c
y = conv(Plain.new(c))
y << "$"
p c
z = String(Plus.new(c))
c << "%"
p z

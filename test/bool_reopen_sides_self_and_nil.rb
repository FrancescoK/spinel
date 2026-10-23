# A call on true or false where TrueClass or FalseClass defines the method
# (#9995): an identity name the class defines answers its own value, a
# parameter default reads the receiver as self, and an Integer or Float
# that can be nil keeps its nil, beside another side's String (boxed) or
# the builtin's NoMethodError.
class FalseClass
  def itself = "F"
end
class TrueClass
  def tag(s = self.to_s + "!") = s
  def num = (ARGV.size == 0 ? nil : 1)
  def ratio = (ARGV.size == 1 ? nil : 2.5)
  def half = (ARGV.size == 0 ? nil : 0.5)
end
class FalseClass
  def num = "f"
end
t = ARGV.size == 0
f = ARGV.size == 1
p false.itself
p true.itself
p t.tag
p t.tag("given")
p((f.tag rescue $!.class))
p t.num
p f.num
p t.ratio
p t.half
p((f.half rescue $!.class))

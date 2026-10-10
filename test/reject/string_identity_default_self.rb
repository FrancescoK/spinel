# Returning a self-valued default copies the receiver in the default build.
# Its later mutation must be refused when the caller reads the receiver.
class String
  def value_default(b = self) = b
end
s = +"x"
t = s.value_default
t << "!"
p [s, t]

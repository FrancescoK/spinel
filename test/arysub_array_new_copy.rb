# Array.new(x) of an Array subclass instance x copies its elements into a
# new plain Array, as of any Array. A splat of a new instance spreads it.
class T < Array
  def tag = "T"
  def mk = Array.new(self)
end

class F < Array; end

t = T.new([1, 2])
a = Array.new(t)
p a
p a.class
p a.equal?(t)
a << 3
p t
p a

u = T.new
u << 7
p Array.new(u)
p Array.new(T.new)
p Array.new(T.new([4, 5]))
p Array.new(F.new([1.5, 2.5])).sum

def cp(x) = Array.new(x)
p cp(t)
p t.mk
p ::Array.new(t)

p [*T.new([1, 2]), 3]
x, y = T.new([5, 6])
p x, y

# a T that may be nil: nil is no size
def copy_of(x)
  Array.new(x)
rescue TypeError => e
  e.message
end
p copy_of(T.new([7]))
p copy_of(nil)

# An exception's message compared by identity with a receiver of no known
# type that holds it, in a program that defines an `equal?` of its own: the
# call dispatches on the receiver's class, and a receiver of no class that
# defines one compares the message as the call without that class does.
# The dispatch held the message as a box of a copy of its bytes, which the
# receiver's box of the message never equals. Also the message read through
# a value of no known type, another String, a user exception's message, and
# a receiver whose class answers `equal?` itself.
class W
  def equal?(o) = true
end

class AppErr < StandardError
end

n = ARGV.size
e = StandardError.new(+"bm#{n}")
m = e.message
z = n == 0 ? m : 3
p z.equal?(e.message), z.equal?(e.to_s)
x = n == 0 ? e : 3
p z.equal?(x.message)
w = n == 0 ? (+"other") : 3
p w.equal?(e.message)
y = n == 0 ? e.message : nil
p y.equal?(e.message)
a = AppErr.new(+"app#{n}")
am = a.message
az = n == 0 ? am : :sym
p az.equal?(a.message)
v = n == 0 ? W.new : 3
p v.equal?(e.message)
u = n == 0 ? 3 : W.new
p u.equal?(e.message)

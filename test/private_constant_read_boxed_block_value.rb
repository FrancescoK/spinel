# A private constant read through its scope raises NameError; as the value
# of a block whose yield is boxed (its sites' blocks answer an Integer, a
# String), the read is still the raise, rescued in the method.
class P
  A = 1
  private_constant :A
end
def t
  x = yield
  p x
rescue NameError => e
  p [e.class, e.message]
end
t { 1 }
t { "s" }
t { P::A }
p((P::A rescue :rescued))

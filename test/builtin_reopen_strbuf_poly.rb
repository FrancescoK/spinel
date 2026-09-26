# A String reopen's method reached through a POLY receiver that holds a
# MUTABLE string: a shared-mutable string travels boxed as a handle (an
# object box, not the plain string tag the String arm keys on), so the
# dispatch never selected the String arm for it and the call took Object's.
# The handle has to reach the reopen with its live value as self, before
# and after a mutation, with and without an argument.
class Object
  def kind = "obj"
  def kind2(x) = "obj#{x}"
end
class String
  def kind = "str#{length}"
  def kind2(x) = "str#{length}#{x}"
end

s = +"ab"
xs = [s, "lit", 1, nil]
xs.each { |x| print x.kind, " " }
puts
s << "cd"
xs.each { |x| print x.kind, " " }
puts
xs.each { |x| print x.kind2("!"), " " }
puts
t = +""
u = [t, 5].first
p u.kind
t << "xyz"
p u.kind

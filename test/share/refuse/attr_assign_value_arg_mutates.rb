# A call over an attribute assignment whose argument changes the String: the
# receiver would be read before the argument runs, and be a copy.
class K
  attr_accessor :a
end
o = K.new
s = +"s"
x = (o.a = s) + (s << "3")
p x, s, o.a
p 1

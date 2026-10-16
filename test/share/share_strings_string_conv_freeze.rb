# Flag-only. Freezing the String a Kernel#String conversion answers freezes
# the String the object holds, as the direct `obj.to_s.freeze` does: the
# call is that String, held by the object and by the local c. (Freezing
# changes no bytes; the frozen state shows through every name.)
class A
  def initialize(n) = @n = n
  def to_str = @n
end
class Named
  def initialize(name) = @name = String(name).freeze
  attr_reader :name
end
c = +"c"
String(A.new(c)).freeze
p c.frozen?
d = +"d"
s = String(A.new(d))
s.freeze
p d.frozen?, s.frozen?
e = +"e"
A.new(e).to_str.freeze
p e.frozen?
f = +"f"
n = Named.new(A.new(f))
p f.frozen?, n.name.frozen?
g = +"g"
p String(A.new(g)).frozen?, g.frozen?

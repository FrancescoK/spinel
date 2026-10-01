# A proc or a Method read out of a mixed Array is called by [] whatever its
# argument is: the caller's String, nil, an Integer (#6179).
def grow(s) = (s << "!" if s; s)
pr = [proc { |t| t << "?" if t; t }, "x"]
ms = [method(:grow), 1]
s = +"q"
pr[0][s]
p s
p pr[0][nil]
ms[0][s]
p s
p ms[0][nil]
p ms[0].call(nil)
ids = [proc { |v| v }, 2]
p ids[0][nil]
p ids[0]["lit"]
# an UnboundMethod bound, turned into a proc and curried: an open site whose
# target the analysis cannot name, in a program whose only appender it names
class A
  def append(s) = (s << "!")
end
c = +"c"
A.instance_method(:append).bind(A.new).to_proc.curry.call(c)
p c

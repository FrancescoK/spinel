# `Const.method(:sym)` on a constant defined nowhere raises the NameError of
# the constant's read, as CRuby does. The receiver was cast to a pointer
# around that read, and the C did not build. A user class, a method added to a
# builtin class, and a value constant still bind their Methods.
begin
  Zork.method(:x)
rescue NameError => e
  p e.message
end
begin
  m = Missing.method(:call)
  p m.call
rescue NameError => e
  p e.message
end

class K
  def self.a(n) = n * 2
end
p K.method(:a).call(21)

class String
  def self.mk = "made"
end
p String.method(:mk).call

X = "ab"
p X.method(:upcase).call

# An attr or a method's own ivar in a Struct or Data class is no member:
# it stays out of members, the constructor, to_a/to_h, inspect and ==.
D = Data.define(:a)
class D
  attr_reader :extra
end
p D.new(a: 3).a
p D.new(3)
p D.members
p D.new(a: 3).to_h
p D.new(a: 3) == D.new(a: 3)
p D.new(a: 3).extra

S = Struct.new(:a)
class S
  attr_accessor :z
end
p S.members
s = S.new(1)
p s
p s.z
s.z = 9
p s.z
p s.to_a
p s.to_h
p s.size
p s == S.new(1)
p s.values
p s.deconstruct
p s.instance_variables
case s
in [x] then p [:arr, x]
end
case s
in {a:} then p [:hash, a]
end
p s.hash == S.new(1).hash
begin
  s[:z]
rescue NameError => e
  p e.class
end
p S.new(1, 2) rescue p $!.message

T = Struct.new(:a, :b) do
  def c; @c ||= a * 2; end
end
t = T.new(1, 2)
p t.c
p T.members
p t
p t.to_a
p t == T.new(1, 2)
p t.each.to_a

E = Data.define(:x) do
  def m; @m = 5; end
end
p E.new(x: 1)
p E.members

class U < Struct.new(:q, :r)
  attr_reader :w
  def initialize(*) ; super; @w = 7; end
end
u = U.new(1, 2)
p u, u.w, U.members, u.to_a
K = Struct.new(:k, keyword_init: true)
class K; attr_accessor :note; end
p K.new(k: 1)

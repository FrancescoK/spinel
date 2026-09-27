# A Float member or ivar holding nil reads, prints and compares as nil,
# not as the NaN its slot stores for it.
S = Struct.new(:v)
p S.new.v, S.new(1.5).v, S.new(nil).v
p S.new
s = S.new(2.5)
p s.to_h, s.to_a
s.v = nil
p s.v, s.v.nil?, (s.v ? :a : :b), s, s.to_h, s.to_a, s.deconstruct
p S.new(nil) == S.new(nil), S.new(nil) == S.new(0.5)
p S.new(nil).hash == S.new(nil).hash, S.new(nil).eql?(S.new(nil))
case s
in [nil] then puts "nil pattern"
in [x] then puts "other #{x.inspect}"
end
s[0] = 3.5
p s
s[:v] = nil
p s, "<#{s.v}>"

K = Struct.new(:f, keyword_init: true)
p K.new(f: 1.5), K.new, K.new.f

D = Data.define(:w)
p D.new(w: 1.5), D.new(w: nil), D.new(w: nil).w, D.new(w: nil).to_h

class A
  attr_accessor :x
  def initialize(x) = @x = x
  def show = "<#{@x}>"
end
a = A.new(nil)
p A.new(1.5).x, a.x, a.show
y = a.x
p y, y.nil?
a.x = 2.0
p a.x
a.x = nil
p a.x

# A Method bound to a value held by value in C -- a Range of any kind, a
# Float, a Rational, a Complex -- calls the method on that value, as CRuby
# does. A String Range was bound as its member Array (the call crashed or
# answered for the Array), and the others did not build: the bound-method
# self slot is a pointer, and the receiver was cast into it.

p ("a".."c").method(:end).call
p ("a".."c").method(:begin).call
p ("a".."c").method(:first).call
p ("a"..."c").method(:exclude_end?).call
p ("a".."c").method(:include?).call("b")
p ("a".."c").method(:to_a).call
p ("a".."c").method(:min).call
p ("a"..).method(:begin).call
p (.."c").method(:end).call
p (1..3).method(:end).call
p (1...3).method(:exclude_end?).call
p (1..).method(:begin).call
p (1..3).method(:include?).call(2)
p (1..3).method(:to_a).call
p (1.5..3.5).method(:begin).call
p (1.5..3.5).method(:end).call
p (1.5..3.5).method(:include?).call(2.0)
p (..2.5).method(:end).call
p (1.5..).method(:end).call
p 2.5.method(:abs).call
p (-2.5).method(:floor).call
p 2.5.method(:round).call
p 2.5.method(:+).call(1)
p 2.5.method(:to_i).call
p Rational(1, 2).method(:numerator).call
p Complex(1, 2).method(:real).call
p ("a".."c").method(:include?).call("b")
p ("a".."c").method(:member?).call("z")
p ("a".."c").method(:===).call("b")
p ("a".."c").method(:last).call
p ("a".."c").method(:max).call
p ("a".."c").method(:minmax).call
p ("a".."c").method(:size).call
p ("a".."c").method(:to_s).call
p ("a".."c").method(:inspect).call
p ("a".."c").method(:entries).call
p ("a".."c").method(:==).call("a".."c")
p ("a".."c").method(:first).call(2)
p ("a".."c").method(:count).call
p ("a".."c").method(:map).call.to_a
p (1..3).method(:sum).call
p (1..3).method(:===).call(2)
p (1.5..3.5).method(:cover?).call(2)
p (1.5..3.5).method(:exclude_end?).call
p (1.5..3.5).method(:to_s).call
p ("a".."c").method(:cover?).call("bb")
m = ("a".."e").method(:include?)
p %w[a c x].map { |s| m.call(s) }
f = 2.5.method(:+)
p [1, 2].map { |x| f.call(x) }

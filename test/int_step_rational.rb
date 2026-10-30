# An Integer's step with a Rational limit or step, and an Integer Range's
# step by a Rational, walk the exact sequence: the step 1/2 is not the
# Integer 0 ("step can't be 0"), and 2r is not the Integer 2.
1.step(3, Rational(1, 2)) { |v| p v }
p 1.step(3, Rational(1, 2)).to_a
p 1.step(3, Rational(1, 2)).size
p 1.step(3, 2r).to_a
p 1.step(2r, 1).to_a
1.step(Rational(5, 2)) { |v| p v }
1.step(by: Rational(1, 2), to: 2) { |v| p v }
p 3.step(1, Rational(-1, 2)).to_a
p 1.step(2, Rational(1, 2)).map { |v| v * 2 }
p 1.0.step(2, Rational(1, 2)).to_a
p 1.step(2.0, Rational(1, 2)).to_a

def g(a, b)
  out = []
  a.step(b, Rational(1, 3)) { |v| out << v; break if v > 2 }
  out
end
p g(1, 5)
r = 1.step(2, Rational(1, 2)) { |v| break v * 10 if v > 1 }
p r
x = 1.step(2, Rational(1, 2)) { |v| v }
p x
p 1.step(3, Rational(1, 2)).sum
p 1.step(3, Rational(1, 2)).each_slice(2).to_a

p (1..3).step(Rational(1, 2)).to_a
(1..2).step(Rational(1, 2)) { |v| p v }
p (1...3).step(Rational(1, 2)).to_a
p (1..3).step(Rational(1, 2)).size
p (1..3).step(2r).to_a
p (3..1).step(Rational(-1, 2)).to_a
p (1..3).step(Rational(-1, 2)).to_a
y = (1..2).step(Rational(1, 2)) { |v| v }
p y
def h(rg) = rg.step(Rational(1, 2)).to_a
p h(1..2)
p h(1...2)

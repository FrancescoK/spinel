# Under --int-overflow=promote a Rational is held boxed. A computed one
# (`1r / 2`, `x * 3`, `-x`, a local written from one) is a Rational too:
# an Integer's step by it walks the exact Rational sequence. It walked a
# step of 0 and raised "step can't be 0".
1.step(3, 1r / 2) { |x| print x, " " }
puts
p 1.step(2, 1r / 2).to_a
p (1..3).step(1r / 2).to_a
w = 3r / 2
p (1..4).step(w).to_a
s = 1r / 2
p 1.step(2, s).to_a
p((1r / 2).step(2, 1r / 2).to_a)
p 1.step(by: 1r / 2, to: 2).to_a
p 0.step(1, s * 1 / 2).to_a
p 2.step(1, -s).to_a
p 1.step(2, 2 / (s * 8)).to_a
p 1.step(2, (s ** 2) * 2).to_a

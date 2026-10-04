# A boxed Float met by a Complex in +, -, * keeps its Float-classed real
# part, as CRuby's does: a whole Float read as an Integer, so `x + Complex(0,
# 2)` with x = 1.0 read out of a container was (1+2i) where CRuby answers
# (1.0+2i).
x = [1.0, 0][0]
c = [Complex(0, 2), 0][0]
p x + Complex(0, 2), Complex(0, 2) + x, x - Complex(0, 2), x * Complex(1, 2)
p((x + Complex(0, 2)).real.class, (x * Complex(1, 2)).imaginary.class)
p x + c, c + x, c * x, c - x
p [Complex(0, 2), 1.0].sum, [1.0, Complex(0, 2)].reduce(:+)
i = [2, 0][0]
p i + Complex(0, 2), i * Complex(1, 2), [1, Complex(0, 2)].sum

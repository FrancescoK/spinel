# A power of 1 or -1 with a negative exponent is an Integer (1, or -1 for an
# odd exponent), through pow and **, written in place or read out of an
# Array of several kinds; any other base gives the Rational
p 1.pow(-1), (-1).pow(-1), (-1).pow(-2), 1 ** -3, (-1) ** -3, (-1) ** -4
p 1.pow(-1).class, ((-1) ** -3).class
p 2.pow(-1), 2 ** -2, (2 ** -1).class
a = [1, -1, 2, 0, "x"]
p a[0].pow(-1), a[1] ** -1, a[1] ** -2, a[2] ** -1
p a[0].pow(-1).class
begin
  a[3] ** -1
rescue ZeroDivisionError => e
  p e.message
end

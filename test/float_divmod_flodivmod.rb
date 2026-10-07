# Float#divmod (and Integer#divmod with a Float divisor) answers CRuby's
# flodivmod pair: the remainder from fmod and the quotient from the
# remainder, round((x - mod) / y). The quotient had been floor(x / y),
# which disagreed with the remainder wherever x / y rounded up.
p 1.0.divmod(0.1)
p (-1.0).divmod(0.1)
p 3.7.divmod(1.2)
p (-3.7).divmod(1.2)
p 3.7.divmod(-1.2)
p 0.3.divmod(0.1)
p 6.0.divmod(2.0)
p 7.divmod(1.2)
p (-7).divmod(1.2)
p 1.divmod(0.1)
p 5.0.divmod(Float::INFINITY)
p (-5.0).divmod(Float::INFINITY)
p 0.0.divmod(3.0)
xs = [1.0, 7, 3.7, "s"]
p xs[0].divmod(0.1)
p xs[1].divmod(1.2)
p xs[2].divmod(1.2)
q, r = 1.0.divmod(0.1)
p q * 0.1 + r == 1.0
p 3.7 % 1.2 == 3.7.divmod(1.2)[1]
begin
  1.5.divmod(0.0)
rescue ZeroDivisionError => e
  p e.message
end

# Rationalization takes the magnitude of an epsilon, including boxed numbers.
p 0.3.rationalize(Complex(0.01, 0.01))
p 0.3.rationalize(Complex(-0.01, 0))
p 0.3.rationalize(Rational(-1, 100))
["oops", "0.01", +"0.02", nil, true, :small, 0.01,
 Rational(-1, 100), Complex(0.01, 0.01)].each do |epsilon|
  begin
    p 0.3.rationalize(epsilon)
  rescue => e
    p e.class
  end
end

# Integer() and Float() with exception: false convert a Rational, as the
# strict forms do: Integer truncates, Float divides
p Integer(Rational(3, 2), exception: false)
p Float(Rational(3, 2), exception: false)
p Integer(Rational(-3, 2), exception: false)
p Float(Rational(-3, 2), exception: false)
p Integer(Rational(7, 1), exception: false)
p Integer(Rational(0, 1), exception: false)

def third
  Rational(1, 3)
end
p Integer(third, exception: false)
p Float(third, exception: false)

q = [Rational(3, 2), "mixed"][0]
p Integer(q, exception: false)
p Float(q, exception: false)
[Rational(5, 2), Rational(-5, 2), "mixed"].each do |v|
  i = Integer(v, exception: false)
  f = Float(v, exception: false)
  p [i, i.class, f, f.class]
end

# a base takes only a String, so a Rational with one is nil
p Integer(Rational(3, 2), 10, exception: false)
[nil, true, :x, "bad"].each do |v|
  p [Integer(v, exception: false), Float(v, exception: false)]
end

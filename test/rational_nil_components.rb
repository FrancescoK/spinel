# spinel: int64 -- a Bignum component (2**70)
# Kernel#Rational raises TypeError for a nil component, after evaluating both
a = begin; Rational(1, nil); rescue => e; [e.class, e.message]; end
b = begin; Rational(nil, 1); rescue => e; [e.class, e.message]; end
p [a, b]

[1, "bad", 1r, 1.0].each do |v|
  begin
    Rational(v, nil)
  rescue => e
    p [e.class, e.message]
  end
end
begin
  Rational(2**70, nil)
rescue => e
  p [e.class, e.message]
end
begin
  Rational(nil, 2**70)
rescue => e
  p [e.class, e.message]
end
begin
  Rational((puts "numerator"; nil), (puts "denominator"; 1))
rescue => e
  p [e.class, e.message]
end
begin
  Rational((puts "numerator"; 1), (puts "denominator"; nil))
rescue => e
  p [e.class, e.message]
end
begin
  Rational(nil, (raise "argument failure"))
rescue => e
  p [e.class, e.message]
end
def none = nil
begin
  Rational(1, none)
rescue => e
  p [e.class, e.message]
end
begin
  Rational(1.5, nil)
rescue => e
  p [e.class, e.message]
end
p Rational(3, 2), Rational(0, 2)
begin
  Rational(1, 0)
rescue => e
  p [e.class, e.message]
end

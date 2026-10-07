# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# pow is Integer's alone: a Float, Rational or Complex read out of a mixed
# Array raises NoMethodError for it, as in CRuby, where it had answered
# the `**` result. Integers, a Bignum among them, still answer.
xs = [2.75, Rational(1, 2), Complex(1, 1), 3, 2**70, "s"]
[0, 1, 2, 5].each do |i|
  begin
    p xs[i].pow(2)
  rescue NoMethodError => e
    p e.message
  end
end
p xs[3].pow(2)
p xs[3].pow(-1)
p xs[4].pow(2)
p xs[3].pow(4, 5)
p xs[0] ** 2
p xs[1] ** 2

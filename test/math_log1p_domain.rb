# spinel: share
[-2, -2.0, -1.0000000000000002, -Float::INFINITY].each do |x|
  begin
    p Math.log1p(x)
  rescue Math::DomainError => error
    p [error.class, error.message]
  end
end
p Math.log1p(-1)
p Math.log1p(Float::NAN).nan?
p Math.log1p(Float::INFINITY)
p 1.0 / Math.log1p(-0.0)
p 1.0 / Math.log1p(0.0)
p Math.log1p(1.0e-20) == 1.0e-20
p Math.log1p(-1.0e-20) == -1.0e-20

[-2, -2.0, -1, -1.0, 0, 0.5, Rational(-3, 2), Rational(1, 2), nil, "2"].each do |x|
  begin
    p Math.log1p(x)
  rescue => e
    p [e.class, e.message]
  end
end

def argument
  puts "argument"
  -2.0
end
begin
  Math.log1p(argument)
  puts "returned"
rescue Math::DomainError => e
  p [e.class, e.message]
ensure
  puts "ensure"
end
puts "continued"

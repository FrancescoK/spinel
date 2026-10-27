t = Time.at(10)
t += Rational(1, 1_000_000)
p [t.to_i, t.nsec]
t += Rational(-3, 4)
p [t.to_i, t.nsec]
t += Rational(-1, 2)
p [t.to_i, t.nsec]
t += Rational(5, 4)
p [t.to_i, t.nsec]

def advance
  time = Time.at(0)
  3.times { time += Rational(1, 1_000_000) }
  time
end
p advance.nsec

t = Time.at(10)
t += (t = Time.at(100); Rational(1, 4))
p [t.to_i, t.nsec]

t = Time.at(0)
p((t += Rational(1, 2)).nsec)
p((t += Rational(-1, 4)).nsec)

def boxed_offset(offset)
  time = Time.at(0)
  time += offset
  time.nsec
end
p boxed_offset(Rational(1, 1_000_000))
p boxed_offset(0.5)
p boxed_offset(1)
begin
  boxed_offset(nil)
rescue TypeError
  puts "nil is not a time offset"
end

# A Rational or a Bignum against a numeric Range compares with the bounds, as
# CRuby's Range#include? / #=== / #member? / case-when do. include? and
# === answered false (the value was "not an Integer"), a Range read out of
# a mixed slot did too, and `case Rational(9, 4) when 1..3` did not build.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

def m(r)
  [r.include?(Rational(5, 2)), r === Rational(9, 4), r.member?(Rational(7, 2)),
   r.include?(2**70), r.cover?(Rational(1, 2))]
end
t("1..3") { m(1..3) }
t("1...3") { m(1...3) }
t("1..") { m(1..) }
t("literal") { [(1..3).include?(Rational(5, 2)), (1..3) === Rational(5, 2), (1.0..3.0).include?(Rational(5, 2))] }

def kase(x)
  case x
  when 1..2 then :low
  when 2..3 then :high
  else :out
  end
end
t("when") { [kase(Rational(3, 2)), kase(Rational(5, 2)), kase(Rational(7, 2)), kase(2**70)] }
def fkase(x)
  case x
  when 1.0..2.0 then :low
  else :out
  end
end
t("when float range") { [fkase(Rational(3, 2)), fkase(Rational(5, 2))] }

puts "-- boxed"
mix = [(1..3), (1.0..3.0), "x"]
2.times do |i|
  r = mix[i]
  t("#{i}") { [r.include?(Rational(5, 2)), r === Rational(9, 4), r.include?(Rational(7, 2))] }
end

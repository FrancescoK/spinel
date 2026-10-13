# spinel: int64
# A number's division methods given an operand that is no number raise the
# coerce TypeError, whether the receiver is boxed or typed; quo by a Bignum,
# a Rational or a Float divides exactly or as a Float; a Bignum compares
# with nothing that is no number. A Complex divides with a Rational, a
# Bignum computes with a Rational, and a program's own Numeric divides and
# compares as its #to_f.
class Plain; end

def box(v) = [v, "z"][0]

def show(label)
  puts "#{label}: #{yield.inspect}"
rescue TypeError, ZeroDivisionError, ArgumentError => e
  puts "#{label}: #{e.class}: #{e.message.sub(/#<Plain:0x\h+>/, "#<Plain>")}"
end

[:a, "l", nil, true, [1], Plain.new].each do |x|
  show("7.div") { box(7).div(box(x)) }
  show("7.divmod") { box(7).divmod(box(x)) }
  show("7.remainder") { box(7).remainder(box(x)) }
  show("7.quo") { box(7).quo(box(x)) }
  show("2.5.fdiv") { box(2.5).fdiv(box(x)) }
  show("2**70.div") { box(2**70).div(box(x)) }
  show("Rational.quo") { box(Rational(7, 2)).quo(box(x)) }
  show("typed 7.div") { 7.div(box(x)) }
  show("typed 7.divmod") { 7.divmod(box(x)) }
  show("typed 7.quo") { 7.quo(box(x)) }
  show("typed 2**70.div") { (2**70).div(box(x)) }
  show("typed 2**70.quo") { (2**70).quo(box(x)) }
  show("typed 2.5.div") { 2.5.div(box(x)) }
  show("typed 2.5.remainder") { 2.5.remainder(box(x)) }
  show("typed 2.5.modulo") { 2.5.modulo(box(x)) }
  show("typed 2.5.quo") { 2.5.quo(box(x)) }
end

# A program's own Numeric with a #to_f divides as that Float, as
# Numeric#coerce makes it; one without is the TypeError
class WithF < Numeric; def to_f = 2.0; end
class NoF < Numeric; end
[WithF.new, NoF.new].each do |x|
  c = x.class
  show("#{c} 7.div") { box(7).div(box(x)) }
  show("#{c} 7.divmod") { box(7).divmod(box(x)) }
  show("#{c} 7.quo") { box(7).quo(box(x)) }
  show("#{c} 7.fdiv") { box(7).fdiv(box(x)) }
  show("#{c} 2.5.div") { box(2.5).div(box(x)) }
  show("#{c} 2.5.divmod") { box(2.5).divmod(box(x)) }
  show("#{c} 2.5.quo") { box(2.5).quo(box(x)) }
  show("#{c} 2**70.div") { box(2**70).div(box(x)) }
  show("#{c} 2**70.quo") { box(2**70).quo(box(x)) }
  show("#{c} Rational.quo") { box(Rational(7, 2)).quo(box(x)) }
  show("#{c} typed 7.div") { 7.div(box(x)) }
  show("#{c} typed 7.divmod") { 7.divmod(box(x)) }
  show("#{c} typed 7.quo") { 7.quo(box(x)) }
  show("#{c} typed 2**70.div") { (2**70).div(box(x)) }
  show("#{c} typed 2**70.quo") { (2**70).quo(box(x)) }
  show("#{c} typed 2.5.div") { 2.5.div(box(x)) }
  show("#{c} typed 2.5.modulo") { 2.5.modulo(box(x)) }
  show("#{c} typed 2.5.quo") { 2.5.quo(box(x)) }
  show("#{c} typed 2.5.fdiv") { 2.5.fdiv(box(x)) }
end

# A Complex with a Rational, a Bignum or a big Rational divides as a Complex,
# and quo is `/` for one
def parts(z) = z.rectangular.map { format("%.6e", _1.to_f) }
[[Rational(1, 2), Complex(1, 2)], [Complex(4, 8), Rational(1, 2)],
 [2**70, Complex(1, 2)], [Complex(1, 2), 2**70],
 [Rational(2**70, 3), Complex(1, 2)], [Complex(1, 2), Rational(2**70, 3)]].each do |a, b|
  show("#{a.class} / #{b.class}") { parts(box(a) / box(b)) }
  show("#{a.class}.quo #{b.class}") { parts(box(a).quo(box(b))) }
end
show("7.quo Complex") { parts(box(7).quo(box(Complex(1, 2)))) }
show("2.5.quo Complex") { parts(box(2.5).quo(box(Complex(1, 2)))) }
# a real divisor divides each component, keeping its class
show("Complex / 0r") { box(Complex(4, 8)) / box(Rational(0, 1)) }
show("Complex.quo 0r") { box(Complex(4, 8)).quo(box(Rational(0, 1))) }
show("Float Complex / 0r") { box(Complex(4.0, 8.0)) / box(Rational(0, 1)) }
show("Complex / Rational") { box(Complex(1, 2)) / box(Rational(1, 3)) }
show("Float Complex / Rational") { box(Complex(1.0, 2.0)) / box(Rational(1, 10)) }
show("Float Complex / 2**600") { box(Complex(1.0, 2.0)) / box(2**600) }
show("Complex.quo 2") { box(Complex(4, 8)).quo(box(2)) }
show("Complex.quo nil") { box(Complex(4, 8)).quo(box(nil)) }
show("Integer / Complex(0, 0)") { box(7) / box(Complex(0, 0)) }
show("Float / Complex(0, 0)") { box(2.5) / box(Complex(0, 0)) }
show("Rational / Complex(0, 0)") { box(Rational(1, 2)) / box(Complex(0, 0)) }
show("Complex / Complex(0, 0)") { box(Complex(1, 2)) / box(Complex(0, 0)) }
show("Complex / Complex(0.0, 0)") { box(Complex(1, 2)) / box(Complex(0.0, 0)) }
class Slash; def /(o) = :slash; end
begin
  p box(Slash.new).quo(box(Complex(1, 2)))
rescue NoMethodError
  puts "Slash.quo Complex: NoMethodError"
end

# A Bignum beside a Rational computes exactly
[[2**70, Rational(1, 3)], [Rational(1, 3), 2**70]].each do |a, b|
  show("#{a} + #{b}") { box(a) + box(b) }
  show("#{a} - #{b}") { box(a) - box(b) }
  show("#{a} * #{b}") { box(a) * box(b) }
  show("#{a} / #{b}") { box(a) / box(b) }
end

# A program's own Numeric compares as its #to_f beside a number
[2**70, 7, 1.5, Rational(1, 2)].each do |n|
  show("#{n} <=> WithF") { box(n) <=> box(WithF.new) }
  show("#{n} < WithF") { box(n) < box(WithF.new) }
  show("#{n} <=> NoF") { box(n) <=> box(NoF.new) }
end

show("7.quo(2**70)") { 7.quo(2**70) }
show("7.quo(Rational)") { 7.quo(Rational(1, 3)) }
show("7.quo(box 2.5)") { 7.quo(box(2.5)) }
show("7.quo(box 2**70)") { 7.quo(box(2**70)) }
show("7.quo(box 0)") { 7.quo(box(0)) }
show("2**70.quo(3)") { (2**70).quo(3) }
show("2**70.quo(2.5)") { (2**70).quo(2.5) }
show("2**70.quo(Rational)") { (2**70).quo(Rational(1, 3)) }
show("2**70.quo(box 0)") { (2**70).quo(box(0)) }
show("box 2**70.quo(box 3)") { box(2**70).quo(box(3)) }
show("box 2**70.quo(box 2**68 * 3)") { box(2**70).quo(box(2**68 * 3)) }
show("box Rational.quo(box 2**70)") { box(Rational(1, 3)).quo(box(2**70)) }

p((2**70) <=> box(:a))
p(box(2**70) <=> box(nil))
p(box(2**70) <=> box(3))
begin
  box(2**70) < box(:a)
rescue ArgumentError => e
  p e.message
end

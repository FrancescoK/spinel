# spinel: int64 -- 0.1.to_r is 3602879701896397/36028797018963968, past 2^31; not run on a 32-bit target
# Complex#to_i, #to_r and #rationalize answer the same through an Array
# element as on a typed Complex: the real part when the imaginary part is
# an exact zero (#to_r takes 0.0 too), RangeError naming the value otherwise;
# #rationalize rationalizes a Float real part, with an epsilon when given
def t(label)
  r = yield
  p [label, r]
rescue RangeError => e
  puts "#{label}: #{e.message}"
end
a = [Complex(1, 2), Complex(3, 0), Complex(2.5, 0), Complex(1, 0.0), Complex(0.1, 0), 1]
5.times do |i|
  c = a[i]
  t("to_i #{i}") { c.to_i }
  t("to_r #{i}") { c.to_r }
  t("rationalize #{i}") { c.rationalize }
end
t("rationalize eps") { a[4].rationalize(Rational(1, 100)) }
c = Complex(0.1, 0)
t("typed rationalize") { c.rationalize }
t("typed rationalize eps") { c.rationalize(Rational(1, 100)) }
t("typed rationalize imag") { Complex(1, 2).rationalize }
t("typed rationalize 0.0 imag") { Complex(1, 0.0).rationalize }
t("typed integer") { Complex(3, 0).rationalize(0.5) }
# an Integer part ignores the epsilon, as Integer#rationalize; the imaginary
# part is checked before it is read; a Float part asks it for #abs
def u(label)
  p yield
rescue RangeError, NoMethodError => e
  puts "#{label}: #{e.class}: #{e.message}"
end
u("integer part nil eps") { Complex(1, 0).rationalize(nil) }
u("imag nil eps") { Complex(1, 2).rationalize(nil) }
u("float part nil eps") { Complex(0.1, 0).rationalize(nil) }
u("boxed integer part nil eps") { a[1].rationalize(nil) }

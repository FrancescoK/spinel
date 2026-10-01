# A Bignum divided by a Float divides in floats, as CRuby converts the Bignum
# to its nearest double: div answers the Integer floor of the quotient,
# divmod CRuby's [Integer, Float] pair, modulo and remainder a Float. The
# Float went into the Bignum division truncated, so (2**64).div(1.5)
# divided by 1.

def big(n = 0)
  2**64 + n
end
b = big
p b.div(1.5)
p b.div(-1.5)
p b.divmod(2.5)
p b.divmod(-2.5)
p((-b).divmod(2.5))
p b.modulo(2.5)
p b.modulo(-2.5)
p b % 2.5
p b.remainder(-2.5)
p b.divmod(Float::INFINITY)
p b.div(Float::INFINITY)
[-> { b.div(0.0) }, -> { b.div(Float::NAN) }, -> { b.divmod(0.0) }, -> { b.divmod(Float::NAN) },
 -> { b % 0.0 }, -> { b.remainder(0.0) }, -> { b.div(1e-300) }].each do |f|
  begin
    p f.call
  rescue ZeroDivisionError, FloatDomainError => e
    puts "#{e.class}: #{e.message}"
  end
end
q = b.div(4.0)
p q, q.class

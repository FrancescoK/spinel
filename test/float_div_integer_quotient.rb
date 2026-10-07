# spinel: int64
# Numeric#div by a Float floors the real quotient into an Integer, on every
# receiver: a typed Float, Integer or Rational, a boxed one, and
# Integer#ceildiv, which is -div(-other). A NaN quotient is FloatDomainError
# and a zero divisor ZeroDivisionError. The typed Float and Rational forms
# cast a NaN quotient to an integer (2.5.div(Float::NAN) answered 0, a
# Rational's crashed); the boxed form answered a NaN or wide quotient as a
# Float; a boxed ceildiv divided with `/` (7.ceildiv(2.5) answered 2.8).
#
# A Rational divisor divides exactly, the floor of the exact quotient. Read
# through a double, Rational(2**60 - 1, 2**60) is 1.0, so a boxed
# 1.ceildiv of it answered 1 (CRuby: 2), and a big Rational raised; a typed
# receiver's ceildiv raised TypeError for every Rational. A typed receiver
# read a boxed Bignum, Rational or Float divisor as an Integer
# (7.div(2**65) raised ZeroDivisionError, (2**70).div(2.5) answered 2**69),
# and a typed Bignum's div by a typed Rational was refused at compile time.
#
# divmod, modulo, % and remainder by a Rational are exact as well: they read
# the Rational as an Integer (7.divmod(Rational(-3, 2)) answered [-7, 0]), as
# 0 beside a Bignum, or raised for a big Rational. A quotient past the word is
# never answered silently: the default build raises RangeError, and promote
# answers the Bignum (promote_float_div_bignum.rb). A boxed Bignum's divmod by
# a Float answered a Float quotient and its remainder 0.0. A typed Integer
# by a typed Rational raised "Rational out of sp_int range" where only its
# word-sized intermediate a * b.den overflowed (7 % Rational(1, 2**62) is 0).
f = 2.5 + ARGV.size
x = [f, "a"][0]            # a boxed Float
n = [7, "a"][0]            # a boxed Integer
p [f.div(0.5), x.div(0.5), n.div(2.5), 7.div(2.5), x.div(-0.75), (-f).div(Float::INFINITY)]
p [(f.div(Float::NAN) rescue $!.class), (2.5.div(Float::NAN) rescue $!.class),
   (x.div(Float::NAN) rescue $!.class), (n.div(Float::NAN) rescue $!.class)]
p [(f.div(0.0) rescue $!.class), (x.div(0.0) rescue $!.class),
   (Float::INFINITY.div(2) rescue $!.class), x.div(Float::INFINITY)]
r = Rational(1, 3)
p [r.div(0.1), (r.div(Float::NAN) rescue $!.class), (r.div(0.0) rescue $!.class)]
p [n.ceildiv(2.5), 7.ceildiv(2.5), n.ceildiv(-2.5), n.ceildiv(3)]
p [(n.ceildiv(Float::NAN) rescue $!.class), (7.ceildiv(Float::NAN) rescue $!.class)]
p x.div(1e-300)
def big
  2**64
end
d = Rational(2**60 - 1, 2**60)
bd = [d, "a"][0]                        # a boxed Rational
br = [Rational(2**70 + 1, 3), "a"][0]   # a boxed big Rational
b = 2**70 + ARGV.size                   # a typed Bignum
bb = [b, "a"][0]                        # a boxed Bignum
p [1.ceildiv(d), (-1).ceildiv(d), 1.ceildiv(bd), n.ceildiv(d), n.ceildiv(bd),
   7.ceildiv(Rational(3, 2)), 7.ceildiv(Rational(-3, 2)), (-n).ceildiv(Rational(3, 2))]
p [1.div(bd), (-1).div(bd), (-1).div(d), n.div(d), (-n).div(bd), 7.div(Rational(-3, 2))]
p [b.ceildiv(d), b.ceildiv(bd), bb.ceildiv(d), (-bb).ceildiv(bd)]
p [b.div(Rational(3, 2)), b.div(bd), bb.div(d), (-b).div(bd), big.div(Rational(4, 1))]
p [7.div(br), n.div(br), b.div(br), bb.ceildiv(br), 7.ceildiv(br), n.ceildiv(br)]
p [7.div([2**65, "a"][0]), (-7).div([2**65, "a"][0]), b.div(x), b.div(-x)]
p [(7.ceildiv(Rational(0, 1)) rescue $!.class), (n.ceildiv([Rational(0, 1), "a"][0]) rescue $!.class),
   (b.div([Rational(0, 1), "a"][0]) rescue $!.class)]
h = [Rational(-3, 2), "a"][0]            # a boxed Rational
t = Rational(1, 2**64)                  # a big Rational
p [7.divmod(h), n.divmod(h), 7.modulo(h), 7 % h, n % h, 7.remainder(h), b.divmod(h), bb.divmod(h)]
p [b % h, b.modulo(h), bb.modulo(h), b.remainder(h), bb.remainder(Rational(3, 2)),
   7.divmod(br), n % br, b % t, bb.divmod(t)]
p [7.divmod(x), 7.modulo(x), bb.divmod(2.5), bb.remainder(x), (-bb).remainder(2.5),
   (n.divmod(Float::NAN) rescue $!.class)]
p [(7.div(t) rescue nil), (7.ceildiv(t) rescue nil), (7.div([t, 1][0]) rescue nil)].map { |v| v.nil? || v > 2**64 }
q62 = Rational(1, 2**62)
w = Rational(2**62 - 1, 3)
p [7 % q62, 7.modulo(q62), (-7) % q62, 7.remainder(q62), 7.divmod(q62), (-7).divmod(q62)]
p [(2**62).div(w), (2**62).divmod(w), (2**62) % w, (-(2**62)).div(w), (2**62).remainder(-w)]

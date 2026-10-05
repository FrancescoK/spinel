# String#equal? is pointer identity. Every string literal is frozen, and
# equal frozen literals are one object (CRuby with
# --enable-frozen-string-literal); aliases and self-comparison hold.
a = "abc"
b = "abc"
p a.equal?(b)        # two occurrences of one frozen literal: one object
p a.equal?(a)
c = a
p a.equal?(c)        # alias preserves identity
d = "ab" + "c"
e = "ab" + "c"
p d.equal?(e)        # heap strings are always distinct
p a == b             # content equality unaffected
h = { "k" => 1 }
p h["k"]             # hash keys compare by content, unaffected
p "".equal?("")      # the empty literal too
# value-embedded types: identity IS the value (flonum-style immediates)
x = Complex(2, 3)
p x.equal?(x)
p 1.0.equal?(1.0)
p 1.0.equal?(2.0)
r = Rational(1, 2)
p r.equal?(r)

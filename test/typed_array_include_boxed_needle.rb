# spinel: int64
# A boxed needle (a parameter that takes several kinds) into a typed
# Integer or Float Array: a Rational, a Bignum or a Float into an Integer
# Array is found by value, as CRuby's == finds it.
def g(a, x) = a.include?(x)
def gi(a, x) = a.index(x)
def gr(a, x) = a.rindex(x)
p g([1, 2], 2r), g([1, 2], 3), g([1, 2], 2.0), g([1, 2], "2"), g([1, 2], nil), g([1, nil], nil)
p gi([1, 2], 2r), gi([1, 2], 3), gi([1, 2], 2.0), gi([1, 2], :a), gr([2, 2], 2r)
p g([1.0, 2.0], 2r), g([1.0, 2.0], 2), g([2.0**70], 2**70), g([1.0], "x"), g([1.0, nil], nil)
p gi([1.0, 2.0], 2r), gi([1.0, 2.0], 2), gr([2.0, 2.0], 2r), gi([1.0], nil)
x = [2r, 5][0]; p [1, 2].include?(x), [1, 2].index(x), [1.0, 2.0].include?(x)
o = Object.new; p g([1], o), gi([1.0], o)

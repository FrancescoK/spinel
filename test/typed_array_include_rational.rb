# spinel: int64
# An Integer or Float Array searched for a number of another kind that ==
# still finds: Integer#== and Float#== compare a Rational by value, and a
# Float compares a Bignum by value. include?, member?, index, rindex and
# find_index answered as if no element could match.
a = [1, 2, 3, 2]
f = [1.0, 2.0, 0.5]
p a.include?(2r)
p a.member?(3r)
p a.include?(5r)
p a.index(2r)
p a.rindex(2r)
p a.find_index(3r)
p a.index(5r / 2)
p f.include?(2r)
p f.index(1r / 2)
p f.rindex(1r)
p f.include?(3r)
big = [2.0**70, 1.0]
p big.include?(2**70)
p big.index(2**70)
p [1.0].include?(2**70)
p [1, 2].include?(2**70)
w = [1, nil, 2]
p w.include?(2r)
p w.index(2r)
def has(x) = [3, 4].include?(x)
p has(4r)
p [].include?(1r)
p [1, 2].include?(2**70 / 2**69)
o = Object.new
p a.include?(o)
p a.index(o)
# a class with only === is not asked by Integer#==
class T
  def ===(o) = true
end
p a.include?(T.new)

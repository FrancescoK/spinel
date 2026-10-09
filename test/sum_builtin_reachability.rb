# spinel: share
# A sum of builtin values never calls an unrelated user's coerce or +.
class UnusedSumOperator
  def coerce(n)
    [self, self]
  end
  def +(other)
    eval(ARGV[0])
  end
end
UnusedSumOperator.new
p [1, 2].sum
p [1, 2].sum(0.0)
p [1, 2].sum { |x| x }
p [1, 2].sum { |x| next 1 if x == 1; x }
p (1..2).sum
p [1, 2].sum(0r) { |x| 1r }

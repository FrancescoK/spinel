# A class's own `!=` and `!` take their arguments as any call binds them:
# `w != [1, 2, 3]` passes the Array as one argument to a rest parameter,
# `!x` passes none, an optional parameter keeps its default, and an
# explicit `w.!=(1, 2)` passes both and answers what the method returns.
class W
  def !=(*a) = a.length
  def <=(*a) = a.length
  def ==(*a) = a.length == 1
end
w = W.new
p(w != [1, 2, 3])
p(w <= [1, 2, 3])
p(w == [1, 2, 3])
p w.!=([1, 2, 3])
p w.!=(1, 2)

class X
  def !(*a) = [:bang, a]
end
p(!X.new)
p X.new.!(1, 2)

class Y
  def !=(o, k = 1) = [o, k]
end
p(Y.new != 3)
p Y.new.!=(3, 4)

class Z
  def !=(o) = o * 2
end
p(Z.new != 21)

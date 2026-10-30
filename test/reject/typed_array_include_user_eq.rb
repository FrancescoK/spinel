# Integer#== hands a compare with a user object to that object's ==, so
# `[1, 2].include?(P.new)` is true in CRuby. The typed Integer Array's scan
# cannot call it: refused, not answered false.
class P
  def ==(o) = o == 2
end
p [1, 2].include?(P.new)
p [1.0, 2.0].index(P.new)

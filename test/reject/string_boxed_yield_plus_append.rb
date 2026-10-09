# A block that appends through a unary plus of its parameter appends to the
# parameter itself unless it is frozen; in the default build the String it
# was handed is a copy, so the append would not reach the caller's String.
class String
  def po(a) = yield(a)
end
u = +"mm"
(+"ab").po(u) { |v| (+v) << "%"; 0 }
p u

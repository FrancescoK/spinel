# An ivar written in a method a program adds to String is kept on the
# String, as CRuby's is: the runtime's table is keyed by the String's
# shared handle, which the share walk gives a String such a method is
# called on. A read alone is nil, as it is for a String nothing was set on.
class String
  def mark(v) = (@mark = v)
  def marked = @mark
end
s = +"s"
s.mark(1)
p s.marked

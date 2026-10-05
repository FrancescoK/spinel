# An ivar written in a method a program adds to String: CRuby keeps it on
# the string, but Spinel copies a String rather than sharing it, so it has
# no identity for the variable yet (#6765) and the write is refused rather
# than compiled to a variable that would be lost. A read alone is nil, as
# it is for a String nothing was set on.
class String
  def mark(v) = (@mark = v)
  def marked = @mark
end
s = +"s"
s.mark(1)
p s.marked

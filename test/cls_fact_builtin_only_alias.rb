# spinel: share
# An alias that captured a builtin (`alias old_dup dup`, #8914) answers the
# builtin's value, a copy of the receiver, even where the class defines its
# own method of the name after the alias: the call's class fact holds the
# receiver's class, not what the class's own method answers.
class Other
  def tag = "other"
end
class Own
  alias old_dup dup
  def initialize(t) = (@t = t)
  def copy = old_dup
  def tag = "own #{@t}"
  def dup = "own dup"
end
[Other.new, Own.new("x").copy].each { |o| puts o.tag }

# A bare call in a program's method on a reopened Time (or Range, File,
# Class) is tried on `self`; one the inference cannot type (here a name
# nothing defines, in a method nothing calls) gives the receiver back for
# the round. The `self` it was tried on was a new node each round, so the
# program grew every round, and under --share-strings the rule waiting for
# the types to hold still saw them move every round: the fixpoint ran to
# its cap (activesupport's Time reopens have such calls).
class Time
  def stamp = formatted_somehow(year)
end

p Time.at(0).utc.year

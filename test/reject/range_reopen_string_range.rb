# A method the program defines in Range, or in a module it prepends to
# Range, has a body for an Integer Range alone: a Range of Strings would
# answer with the builtin's first in its place (CRuby prints :mine), so
# the call is refused, not answered wrongly.
module Overrides
  def first = :mine
end
class Range
  prepend Overrides
end
p (1..3).first
p ("a".."c").first

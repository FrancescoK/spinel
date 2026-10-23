# A module prepended to Range through a constant that aliases it answers
# first in the builtin's place; its method is compiled for an Integer Range
# alone, so the call on a Range of Strings is refused, not answered with
# the builtin's endpoint.
$g = String.new("other")
module Overrides
  def first = $g
end
Alias = Overrides
class Range
  prepend Alias
end
s = String.new("a")
e = String.new("c")
r = s..e
x = r.first
t = x
x << "!"
p t, s, e, $g

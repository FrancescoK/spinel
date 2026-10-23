# A module prepended to Range through a chain of constants that alias it
# answers first in the builtin's place; its method is compiled for an
# Integer Range alone, so the call on a Range of Strings is refused, not
# answered with the builtin's endpoint.
$g = String.new("other")
module Overrides
  def last = $g
end
Inner = Overrides
Outer = Inner
class Range
  prepend Outer
end
s = String.new("a")
e = String.new("c")
r = s..e
x = r.last
t = x
x << "!"
p t, s, e, $g

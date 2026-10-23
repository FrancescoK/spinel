# spinel: not-cruby
# A module prepended to Range through a constant that aliases it may
# answer first in the builtin's place, as one prepended by its own name
# does: its answer kept under two names and changed stays refused, rather
# than handing on the builtin's endpoint.
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

# spinel: not-cruby
# A reopened Range#first, which a String Range's value never reaches (an
# old dispatch gap): its answer kept under two names and changed stays
# refused, rather than handing on the builtin's endpoint.
$g = String.new("other")
class Range
  def first = $g
end
s = String.new("a")
e = String.new("c")
r = s..e
x = r.first
t = x
x << "!"
p t, s, e, $g

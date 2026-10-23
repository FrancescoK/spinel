# A reopened Range#first is compiled for an Integer Range alone, so the
# call on a Range of Strings is refused, not answered with the builtin's
# endpoint.
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

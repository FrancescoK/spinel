# A reopened Range#take is compiled for an Integer Range alone, so the
# call on a Range of Strings is refused, not answered with the builtin's
# elements.
class Range
  def take(n) = [self.begin]
end
s = String.new("a")
r = s..(+"d")
y = r.take(1)[0]
s << "?"
p y, r

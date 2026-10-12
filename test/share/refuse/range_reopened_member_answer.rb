# spinel: not-cruby
# A reopened Range's take, which the program's values never reach (an old
# dispatch gap): the facts take no builtin answer for granted, so an
# element read of it, kept under two names and changed, stays refused.
class Range
  def take(n) = [self.begin]
end
s = String.new("a")
r = s..(+"d")
y = r.take(1)[0]
s << "?"
p y, r

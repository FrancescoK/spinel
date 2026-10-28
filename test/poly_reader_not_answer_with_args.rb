# An attr_reader takes no argument, so a boxed receiver's call that passes
# one is not answered by the reader: `m.end(1)` beside an `attr_reader :end`
# holding a Time is the MatchData's Integer, also where it is asked inside
# another MatchData call's argument
class Event
  attr_reader :end
  def initialize(e) = @end = e
end

def pick(a, b, flag) = flag ? a : b

ev = Event.new(Time.at(0))
puts ev.end.class
m = pick(ev, "aabbcc".match(/(b+)/), false)
p m.offset("aabbcc"[m.end(1)..].size - 1)
u = "aabbcc"
p u[0...m.begin(1)] + u[m.end(1)..]
p m.end(1) + 1

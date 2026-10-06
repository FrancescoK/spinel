# A splat of a beginless or endless Integer Range raises as CRuby does --
# TypeError for a beginless one, RangeError for an endless one -- in an
# Array literal, a value splat and a multiple assignment. The splat walked
# the markers that stand for the missing bound and looped from INTPTR_MIN
# (a hang), or overflowed its end.

begin
  p([*(..5)])
rescue => e
  p [e.class, e.message]
end

begin
  p([*(...5)])
rescue => e
  p [e.class, e.message]
end

begin
  p([*(1..)])
rescue => e
  p [e.class, e.message]
end

begin
  p([*(1...)])
rescue => e
  p [e.class, e.message]
end

begin
  p([0, *(..5)])
rescue => e
  p [e.class, e.message]
end

begin
  p([0, *(1..)])
rescue => e
  p [e.class, e.message]
end

begin
  p(["x", *(..5)])
rescue => e
  p [e.class, e.message]
end

begin
  p((r = (..5); [*r]))
rescue => e
  p [e.class, e.message]
end

begin
  p((r = (1..); [*r]))
rescue => e
  p [e.class, e.message]
end

begin
  p((a = *(..5); a))
rescue => e
  p [e.class, e.message]
end

begin
  p((a = *(1..); a))
rescue => e
  p [e.class, e.message]
end

begin
  p((x, y = *(1..); x))
rescue => e
  p [e.class, e.message]
end

begin
  p((x, y = *(..3); y))
rescue => e
  p [e.class, e.message]
end

begin
  p([*(1..3), *(5...7)])
rescue => e
  p [e.class, e.message]
end

begin
  p((n = 3; [*(n..n+2)]))
rescue => e
  p [e.class, e.message]
end
def f(*a) = a.size
begin; p f(*(..5)); rescue => e; p e.class; end
begin; p f(*(1..)); rescue => e; p e.class; end
begin; puts(*(..2)); rescue => e; p e.class; end

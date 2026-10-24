# Time.new keeps the fraction of a Float or Rational seconds field, with no
# zone, a zone as the 7th positional (a String or an Integer offset) and the
# in: keyword, as Time.utc and Time.local do.
p Time.new(2026, 3, 4, 10, 20, 30.25r).nsec
p Time.new(2026, 3, 4, 10, 20, 30.25).nsec
p Time.new(2026, 3, 4, 10, 20, 30.25r, "+09:00").nsec
p Time.new(2026, 3, 4, 10, 20, 30.5, "+09:00").subsec
p Time.new(2026, 3, 4, 10, 20, Rational(91, 3), 3600).nsec
p Time.new(2026, 3, 4, 10, 20, 30.75r, in: "-03:00").nsec
p Time.new(2026, 3, 4, 10, 20, 30.75, in: 0).nsec

s = 30.125r
t = Time.new(2026, 3, 4, 10, 20, s, "+09:00")
p [t.sec, t.nsec, t.utc_offset]
f = [12.5, 1][0]
p Time.new(2026, 3, 4, 10, 20, f, "Z").nsec

# a whole seconds field is as before
p Time.new(2026, 3, 4, 10, 20, 30, "+09:00").nsec
p Time.new(2026, 3, 4, 10, 20, 30).sec

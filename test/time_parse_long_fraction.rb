# spinel: int64 -- a ten-digit fraction is read as n / 10**10, past 2^31
# Time.parse keeps the nanoseconds of a fraction longer than nine digits
# (the rest is cut, not rounded).
require "time"

t = Time.parse("2026-10-09T10:23:24.1234567891Z")
p [t.to_i, t.nsec, t.utc_offset, t.utc?, t.iso8601(3)]
t = Time.parse("2026-10-09T10:23:24.9999999999+09:00")
p [t.to_i, t.nsec, t.utc_offset, t.utc?, t.iso8601(9)]

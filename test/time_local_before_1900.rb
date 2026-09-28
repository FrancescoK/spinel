# spinel: int64 -- a year before 1901 is outside a 32-bit time_t; not run on a 32-bit target
# macOS mktime refuses years before 1900; the fields must still round-trip.
t = Time.local(1883, 12, 31, 19, 0, 0)
p [t.year, t.month, t.day, t.hour, t.min, t.sec]
p t.utc_offset.abs < 86400
u = Time.at(t.to_i)
p [u.year, u.month, u.day, u.hour, u.min, u.sec]
p u.utc_offset == t.utc_offset
p Time.local(1899, 12, 31, 23, 59, 59) < Time.local(1900, 1, 1, 0, 0, 0)
p Time.local(1800, 2, 30).day
e = Time.local(1969, 12, 31, 23, 59, 59)
p [e.year, e.month, e.day, e.hour, e.min, e.sec]
p Time.at(-2713960800).utc_offset.abs < 86400

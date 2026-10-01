# spinel: int64 -- Time.at(-10_000_000_000) is past a 32-bit integer and time_t
require "time"

# Time#httpdate is always GMT; #rfc2822 (and rfc822) keeps the offset and
# writes a UTC time as -0000
t = Time.at(1700000000, in: "+09:00")
p t.httpdate, t.rfc2822, t.rfc822
u = Time.at(1700000000).utc
p u.httpdate, u.rfc2822
p Time.at(1700000005, in: "-05:30").rfc2822, Time.at(1700000005).getlocal("+00:00").rfc2822
p Time.at(-10_000_000_000).utc.httpdate
# a boxed Time
vals = [t, 1]
p vals[0].httpdate, vals[0].rfc2822

# Time.now(in: zone) reads the current instant in the zone the keyword names,
# as Time.at(t, in: zone) does: an offset string, an Integer offset, "UTC" or
# "Z", a String or Integer variable, or nil for local time. It raised
# NoMethodError at run time.
p Time.now(in: "+05:00").utc_offset
p Time.now(in: "-03:30").utc_offset
p Time.now(in: "-09:00:01").utc_offset
p Time.now(in: "+0900").utc_offset
p Time.now(in: 3600).utc_offset
u = Time.now(in: "UTC")
p [u.utc?, u.utc_offset, u.zone]
z = Time.now(in: "Z")
p [z.utc?, z.zone]
p Time.now(in: nil).utc_offset == Time.now.utc_offset
off = ["+01:00", 7200][ARGV.size]
p Time.now(in: off).utc_offset
s = "+02:30"
p Time.now(in: s).utc_offset
t = Time.now(in: "+05:00")
p [t.zone, t.strftime("%z"), (t.to_i - Time.now.to_i).abs <= 60]
p((Time.now(in: "bogus") rescue $!.class))
p((Time.now(in: 86400) rescue $!.message))

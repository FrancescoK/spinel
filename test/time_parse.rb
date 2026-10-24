# Time.parse (`require "time"`) for the numeric ISO 8601 forms: the instant,
# the zone and the fraction as CRuby's. A zone after the time puts the
# instant there (UTC for Z / UTC / UT / -00:00, which are utc?; GMT and the
# other names and offsets are a fixed offset, not utc?). A zoneless string is
# local time, checked against Time.new so the test holds in any TZ.
require "time"

def show(t)
  [t.to_i, t.nsec, t.utc_offset, t.utc?, t.iso8601(3)]
end

p show(Time.parse("2026-10-09T10:23:24Z"))
p show(Time.parse("2026-10-09T10:23:24.123Z"))
p show(Time.parse("2026-10-09t10:23:24z"))
p show(Time.parse("  2026-10-09T10:23:24Z  "))
p show(Time.parse("2026-10-09T12:23:24+02:00"))
p show(Time.parse("2026-10-09 12:23:24 +0200"))
p show(Time.parse("2026-10-09 10:23:24.5 -05:00"))
p show(Time.parse("2026-10-09 10:23:24-0500"))
p show(Time.parse("2026-10-09T10:23:24+02"))
p show(Time.parse("2026-10-09 10:23:24 +05:30"))
p show(Time.parse("2026-10-09 10:23:24 UTC"))
p show(Time.parse("2026-10-09 10:23:24 utc"))
p show(Time.parse("2026-10-09 10:23:24 UT"))
p show(Time.parse("2026-10-09 10:23:24 -00:00"))
p show(Time.parse("2026-10-09 10:23:24 GMT"))
p show(Time.parse("2026-10-09 10:23:24 EST"))
p show(Time.parse("2026-10-09 10:23:24 PDT"))
p show(Time.parse("2026-10-09T10:23:24.Z"))
p Time.parse("2026-10-09T10:23") == Time.new(2026, 10, 9, 10, 23)
p Time.parse("2026-10-09  1:02") == Time.new(2026, 10, 9, 1, 2)
t = Time.parse("2026-10-09 10:23:24.25")
p [t.to_i == Time.new(2026, 10, 9, 10, 23, 24).to_i, t.nsec]
p Time.parse("2026-10-09") == Time.new(2026, 10, 9)
p Time.parse("2026-1-9") == Time.new(2026, 1, 9)
p Time.parse("2026-10-09 24:00") == Time.new(2026, 10, 10)
t = Time.parse("2026-02-30 10:00")
p [t.year, t.month, t.day, t.hour]
p show(Time.parse("2026-10-09 10:23:60Z"))
p Time.parse("2026-10-09").utc_offset == Time.new(2026, 10, 9).utc_offset
p Time.parse("2026-10-09").utc?
["", "   ", "2026-13-01", "2026-10-09 25:00", "2026-10-09 10:60"].each do |s|
  Time.parse(s)
rescue ArgumentError => e
  puts e.message
end
begin
  Time.parse(nil)
rescue TypeError => e
  puts e.message
end

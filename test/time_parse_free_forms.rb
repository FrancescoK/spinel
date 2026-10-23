require "time"
ENV["TZ"] = "UTC"
now = Time.utc(2026, 1, 15, 12, 0, 0)
p Time.parse("Thu, 22 Oct 2026 08:34:39 GMT")
p Time.parse("Oct 22 2026 10:00 +0900")
p Time.parse("Wed Mar 4 10:00:00 2026")
p Time.parse("10:20", now)
p Time.parse("26-03-04") { |y| y + 2000 }
p Time.parse("2026-03-04 10:00 EST").utc_offset
p Time.parse("2026-03-04T10:20:30.123456Z").usec
begin; Time.parse("foo"); rescue ArgumentError => e; p e.message; end
begin; Time.parse(""); rescue ArgumentError => e; p e.message; end
# in this program the formatters are time.rb's Ruby, not the runtime's C
t = Time.new(2026, 3, 4, 10, 20, 30, "+09:00")
puts t.iso8601(3), t.httpdate, t.rfc2822, t.xmlschema

# require "time"'s class parsers that read one fixed format: Time.httpdate
# (RFC 1123, RFC 850, asctime), Time.rfc2822 / rfc822, Time.xmlschema /
# iso8601. Each answers a Time, or CRuby's ArgumentError for a String not in
# its format. Printed as epoch seconds, UTC flag and offset, which do not
# depend on the host's zone.
require "time"

def show(t) = puts("#{t.to_i} #{t.nsec} utc=#{t.utc?} off=#{t.utc_offset}")
def try
  show(yield)
rescue => e
  puts "#{e.class}: #{e.message}"
end

try { Time.httpdate("Sun, 06 Nov 1994 08:49:37 GMT") }
try { Time.httpdate("  sun, 06 nov 1994 08:49:37 gmt  ") }
try { Time.httpdate("Sunday, 06-Nov-94 08:49:37 GMT") }
try { Time.httpdate("Thursday, 06-Nov-31 08:49:37 GMT") }
try { Time.httpdate("Sun Nov  6 08:49:37 1994") }
try { Time.httpdate("Sun Nov 16 08:49:37 1994") }
try { Time.httpdate("Sun, 06 Nov 1994 08:49:37 +0000") }
try { Time.httpdate("2026-10-11") }
try { Time.httpdate(nil) }

try { Time.rfc2822("Sun, 06 Nov 1994 08:49:37 +0900") }
try { Time.rfc2822("6 Nov 94 08:49 -0500") }
try { Time.rfc2822("06 Nov 1994 08:49:37 GMT") }
try { Time.rfc2822("Sun , 06 Nov 1994 08 : 49 : 37 EST trailing") }
try { Time.rfc2822("Sun, 06 Nov 1994 08:49:37 -0000") }
try { Time.rfc2822("Sun, 06 Nov 1994 08:49:37 UT") }
try { Time.rfc2822("Sun, 06 Nov 1994 08:49:37 z") }
try { Time.rfc2822("Sun, 06 Nov 1994 08:49:37 A") }
try { Time.rfc822("Sun, 06 Nov 1994 23:49:37 PDT") }
try { Time.rfc2822("Sun, 06 Nov 1994 08:49:37 J") }
try { Time.rfc2822("Sun 06 Nov 1994 08:49:37 GMT") }
try { Time.rfc2822(nil) }

try { Time.xmlschema("2026-10-11T08:49:37Z") }
try { Time.xmlschema("2026-10-11t08:49:37.25+09:00") }
try { Time.iso8601("2026-10-11T08:49:37.123456789-0530") }
try { Time.iso8601("2026-10-11T08:49:37+09") }
try { Time.xmlschema("2026-10-11T08:49:37-00:00") }
try { Time.xmlschema("2026-10-11Z") }
try { Time.xmlschema("2026-10-11T08:49") }
try { Time.xmlschema("2026-13-11T08:49:37Z") }
try { Time.xmlschema(nil) }
# An offset that moves the day past a month's end lands on the 1st of the
# next month, as time.rb's apply_offset does, not days into it.
try { Time.xmlschema("2026-02-31T23:00:00-05:00") }
try { Time.rfc2822("Sun, 31 Feb 1994 23:00:00 -0500") }
try { Time.rfc2822("Sun, 01 Mar 1994 01:00:00 +0500") }
try { Time.xmlschema("2026-12-31T23:30:00-01:00") }
try { Time.rfc2822("Sun, 06 Nov 1994 08:49:37 -0930") }
# A NUL after the date is not trailing whitespace; a non-String is CRuby's
# TypeError (httpdate's NoMethodError).
try { Time.httpdate("Sun, 06 Nov 1994 08:49:37 GMT\0") }
try { Time.xmlschema("2026-10-11T08:49:37Z\0") }
try { Time.rfc2822(123) }
try { Time.xmlschema(1.5) }
[1, nil].each { |x| try { Time.httpdate(x) } }
local = Time.xmlschema("2026-10-11T08:49:37")
p [local.year, local.month, local.day, local.hour, local.min, local.sec, local.utc?]

# Round trips through the instance methods of the same names, and a
# comparison of the result, as a cache check does with If-Modified-Since.
mtime = Time.at(1_700_000_000)
p Time.httpdate(mtime.httpdate) == mtime
p Time.httpdate(mtime.httpdate) >= mtime
p Time.rfc2822(mtime.rfc2822) == mtime
p Time.iso8601(mtime.utc.iso8601) == mtime
header = [nil, "Tue, 14 Nov 2023 22:13:20 GMT"].last
p Time.httpdate(header) >= mtime

# A zero-padded year keeps its value, however many zeros pad it.
try { Time.rfc2822("Mon, 01 Jan 0000000000000000001 10:00:00 +0000") }
try { Time.xmlschema("0000000000000000001-01-01T00:00:00Z") }
p Time.xmlschema("-0000000000000000001-01-01T00:00:00Z").year

# httpdate calls match? on its argument: an object that only converts to a
# String has no match?, while a String subclass does.
class HeaderText < String; end
class HeaderLike
  def to_str = "Sun, 06 Nov 1994 08:49:37 GMT"
end
[HeaderText.new("Sun, 06 Nov 1994 08:49:37 GMT"), HeaderLike.new, Object.new].each do |v|
  begin
    p Time.httpdate(v).to_i
  rescue NoMethodError => e
    puts "NoMethodError #{e.name}"
  end
end

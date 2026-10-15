# Parsing and formatting: Date.parse and the ISO 8601 / RFC 3339 readers,
# strftime, and what a malformed string raises. ruby_llm reads its model
# registry's dates with Date.parse and Date.iso8601.
require "date"

p Date.parse("2025-08-31").to_s
p Date.parse("Aug 31 2025").to_s
p Date.parse("31/08/2025").to_s
p Date.parse("2025-08").to_s rescue p $!.class
p Date.iso8601("2024-05-01").to_s, Date.iso8601("20240501").to_s
p Date.rfc3339("2024-05-06T10:00:00+09:00").to_s
p Date.strptime("06/05/2024", "%d/%m/%Y").to_s
d = Date.new(2024, 5, 6)
p d.strftime("%Y-%m-%d"), d.strftime("%A %B %-d, %Y"), d.strftime("%j %U %a %b %y")
p d.iso8601, d.httpdate, d.rfc3339, d.jisx0301
["nope", "", "2024-13-01"].each do |s|
  begin
    Date.iso8601(s)
    p :parsed
  rescue Date::Error => e
    p [s, e.class]
  end
end
p Date._parse("2024-05-06 10:20")

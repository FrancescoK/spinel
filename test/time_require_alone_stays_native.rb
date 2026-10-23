# require "time" alone keeps the runtime's C formatters: no Time.parse or
# Time.strptime here, so CRuby's time.rb is not spliced in.
require "time"
t = Time.utc(2026, 10, 22, 8, 34, 39)
puts t.iso8601, t.httpdate, t.rfc2822
p Time.iso8601("2026-10-22T08:34:39Z") == t

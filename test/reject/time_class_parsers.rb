# Time.iso8601, xmlschema, httpdate, rfc2822 and rfc822 as class methods parse
# a String, as Time.parse does, and are refused the same way rather than
# compiled into a run-time NoMethodError. The instance methods of the same
# names are supported and compile.
# spinel: reject-time-parse: Time.iso8601 is not supported
require "time"
t = Time.at(0).utc
p Time.iso8601(t.iso8601)
p Time.xmlschema(t.xmlschema)
p Time.httpdate(t.httpdate)
p Time.rfc2822(t.rfc2822)
p Time.rfc822(t.rfc822)

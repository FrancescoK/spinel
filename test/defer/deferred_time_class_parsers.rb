# Compiled with --defer-refusals: the class-method parsers Time.iso8601,
# xmlschema, httpdate, rfc2822 and rfc822 are deferred as Time.parse is --
# each method raises NotImplementedError naming its call, and the program
# runs. Without the flag they are refused.
# spinel: defer-refusals: 6:start true true true true true after
require "time"
def from_iso8601(s) = Time.iso8601(s)
def from_xmlschema(s) = Time.xmlschema(s)
def from_httpdate(s) = Time.httpdate(s)
def from_rfc2822(s) = Time.rfc2822(s)
def from_rfc822(s) = Time.rfc822(s)

def refused?(name)
  yield
  false
rescue NotImplementedError => e
  e.message.include?("Time.#{name} is not supported")
end

puts "start"
puts refused?("iso8601") { from_iso8601("2024-02-29T00:00:00Z") }
puts refused?("xmlschema") { from_xmlschema("2024-02-29T00:00:00Z") }
puts refused?("httpdate") { from_httpdate("Thu, 29 Feb 2024 00:00:00 GMT") }
puts refused?("rfc2822") { from_rfc2822("Thu, 29 Feb 2024 00:00:00 -0000") }
puts refused?("rfc822") { from_rfc822("Thu, 29 Feb 2024 00:00:00 -0000") }
puts "after"
"a".unicode_normalize(:nfd)
puts "not reached"

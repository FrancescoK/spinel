# Compiled with --defer-refusals: a Time.parse in a method is deferred like
# any other refusal -- the method raises NotImplementedError naming it, and
# a program that never calls it (webrick's cookie expiry, activesupport's
# date conversions) builds and runs. Without the flag it is refused.
# spinel: defer-refusals: 2:start true after
require "time"
def expires_at(s) = Time.parse(s)

puts "start"
begin
  expires_at("2024-02-29")
rescue NotImplementedError => e
  puts e.message.include?("Time.parse is not supported")
end
puts "after"
"a".unicode_normalize(:nfd)
puts "not reached"

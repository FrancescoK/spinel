# Time.parse reads the free forms through CRuby's time.rb (packages/time),
# spliced in because the program calls it: these forms read as in CRuby,
# with no NotImplementedError, and "x" is CRuby's ArgumentError.
require "time"

["Oct 9 2026", "Fri, 09 Oct 2026 10:23:24 +0200", "10:23", "2026-10-09 foo",
 "2026-10-09 10:23:24 CEST", "2026-10-09 UTC", "x"].each do |s|
  Time.parse(s)
  puts "read #{s}"
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
rescue NotImplementedError => e
  puts e.message
end

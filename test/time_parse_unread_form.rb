# spinel: not-cruby -- CRuby's Date._parse reads these forms; Spinel's Time.parse reads only the numeric ISO 8601 ones and says so.
# A form Time.parse does not read raises NotImplementedError naming it, not
# an ArgumentError a program would take for an invalid date (CRuby answers a
# Time for each of these), and not some other instant.
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

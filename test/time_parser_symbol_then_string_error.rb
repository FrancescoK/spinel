# A fixed-format Time parser's ArgumentError shows a Symbol argument only
# for the parse that was given it: a Symbol parse that raised another way
# first left the Symbol behind for the next String's message (CodeRabbit
# on #10010).
require "time"
begin
  Time.xmlschema(:"2024-99-99T00:00:00Z")
rescue ArgumentError, RangeError => e
  p e.class
end
begin
  Time.xmlschema("bogus")
rescue ArgumentError => e
  puts e.message
end
begin
  Time.xmlschema(:bogus)
rescue ArgumentError => e
  puts e.message
end

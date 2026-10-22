# OptionParser#getopts and OptionParser.getopts: single letters in one
# String, long names as further arguments, a trailing ":" for a value
# and "name:default" for a long option's default.
require "optparse"

argv = %w[-a -b x --long y --level=3 rest]
p OptionParser.new.getopts(argv, "ab:c", "long:", "level:1", "flag")
p argv

p OptionParser.getopts(%w[-ac], "ab:c")
p OptionParser.new.getopts([], "v", "level:1")

begin
  OptionParser.new.getopts(%w[-z], "ab")
rescue OptionParser::InvalidOption => e
  puts e.message
end
begin
  OptionParser.new.getopts(%w[-b], "b:")
rescue OptionParser::MissingArgument => e
  puts e.message
end

# The same with two requires of the file, which then run at a time the
# entry's order does not fix: the read is still before the write.
require_relative "place_const_lib" if ARGV.empty?
require_relative "place_const_lib" unless ARGV.empty?
LIMIT = 5
p LIMIT

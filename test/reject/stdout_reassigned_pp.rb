# pp does not write through a reassigned $stdout yet: compiled, it would
# print past the StringIO the program stored there.
require "stringio"
io = StringIO.new
$stdout = io
pp [1, 2]
$stdout = STDOUT
p io.string

# A narrowed String keeps its boxed identity through to_s even when an
# unrelated class defines that method (StringIO supplies one).
require "stringio"
StringIO.new("a").each_line(1) { |line| line }
separator = +"b"
lines = []
StringIO.new("abcbdbd\nxbd\n").each_line(separator) do |line|
  lines << line
  separator << "d"
end
p [lines, separator]

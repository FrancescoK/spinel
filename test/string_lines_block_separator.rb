# String#lines with a separator and a block iterates and answers the
# receiver, whatever the separator's kind (a String, a boxed String or nil,
# with or without chomp:); without a block it answers the Array of lines.
# A String separator and a block used to be typed as the Array, so
# assigning the call's value did not compile.
s = "a,b\nc,d\ne"
n = 0

r = s.lines("\n") { |l| n += l.size }
p r.equal?(s), r, n

r = s.lines(",") { |l| puts l.inspect }
p r.equal?(s)

r = s.lines("\n", chomp: true) { |l| puts l.inspect }
p r.equal?(s)

sep = ENV["NO_SUCH_VARIABLE_SET"] ? nil : "\n"
r = s.lines(sep) { |l| puts l.inspect }
p r.equal?(s)

sep = ENV["NO_SUCH_VARIABLE_SET"] ? "\n" : nil
r = s.lines(sep) { |l| puts l.inspect }
p r.equal?(s)

def split_lines(str, sep)
  str.lines(sep) { |l| yield l }
end
p split_lines(s, "\n") { |l| print l.size, " " }.equal?(s)
puts

p s.lines("\n")
p s.lines(",")
p s.lines("\n", chomp: true)
p s.lines(sep)
p s.lines

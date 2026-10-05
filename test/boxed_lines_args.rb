# lines with a separator, chomp: or both on a String held in a mixed
# Array (a boxed receiver) answers as a String does; another kind of
# value raises NoMethodError.
s = [+"Hello World\nfoo\n", 1][0]
p s.lines("o"), s.lines(chomp: true), s.lines("o", chomp: true)
p s.lines(chomp: false), s.lines(""), s.lines
f = ARGV.size > 9
p s.lines(chomp: f), s.lines("\n", chomp: !f)
n = [1, +"x"][0]
begin
  n.lines("o")
rescue NoMethodError => e
  puts e.message
end

# each_line with a separator, chomp: or both on a String held in a mixed
# Array (a boxed receiver) yields the lines those arguments give and
# answers the receiver, or answers the lines without a block, as on a
# String; another kind of value raises NoMethodError.
s = [+"ab\ncd\nef", 1][0]
s.each_line("c") { |l| p l }
r = s.each_line(chomp: true) { |l| p l }
p r
s.each_line("\n", chomp: true) { p _1 }
p s.each_line("b").to_a, s.each_line(chomp: true).to_a, s.each_line("d", chomp: true).to_a
n = 0
s.each_line("c") { |l| n += l.size }
p n
f = ARGV.size > 9
p s.each_line(chomp: f).to_a
x = [2, +"a"][0]
begin
  x.each_line("a") { }
rescue NoMethodError => e
  puts e.message
end
p s.each_line.to_a, s.lines("c")

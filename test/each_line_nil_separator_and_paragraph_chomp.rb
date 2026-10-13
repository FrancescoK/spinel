def maybe(f) = f ? "," : nil
def boxed(x) = [1, x][1]

["a\n\nb\nc\n", "a\nb\n\n", "a\r\n\r\nb\r\n", "a\n\n\r\n\nb\n", "\r\n\r\na", "a\n\n\n"].each do |s|
  p [s.lines(""), s.lines("", chomp: true), s.each_line("", chomp: true).to_a]
end

s = "a,b\n\nc\n"
r = []
s.each_line(nil) { |l| r << l }
p r
r = []
s.each_line(nil, chomp: true) { |l| r << l }
p r
p s.each_line(nil).to_a
p s.each_line(maybe(false)).to_a
p s.each_line(maybe(true), chomp: true).to_a
r = []
s.each_line(boxed(nil)) { |l| r << l }
p r
r = []
boxed(s).each_line(nil) { |l| r << l }
p r

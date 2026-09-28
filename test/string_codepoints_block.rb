# codepoints with a block yields each character's codepoint, as the
# blockless form answers them, and returns the String.
s = "aé€😀"
out = []
r = s.codepoints { |c| out << c }
p out
p r
p s.codepoints == out
n = 0
"日本".codepoints { |c| n += c }
p n
t = +"x"
t << "ÿ"
t.codepoints { |c| print c, " " }
puts
# a NUL is a character, and a binary String's codepoints are its bytes
out = []
"a\0b".codepoints { |c| out << c }
p out
out = []
"é".b.codepoints { |c| out << c }
p out
# a nil receiver raises, as the blockless form does
s = nil
s = "é" if ARGV.size > 5
p((s.codepoints { } rescue $!.message))

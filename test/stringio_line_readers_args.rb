# StringIO#gets, #readline, #readlines, #each_line and #each take a separator,
# a limit and `chomp: true`, and an empty separator reads paragraphs, as
# CRuby's do. A lone Integer is the limit; a limit ends a line at that many
# bytes, rounded up to the end of the character it falls in; a paragraph keeps
# the run of blank lines that ends it and `chomp:` takes that run off.
require "stringio"

def lines(io)
  r = []
  while (l = yield(io))
    r << l
  end
  r
end

def tried
  p yield
rescue => e
  p [e.class, e.message]
end

CONTENTS = [
  "a\nb\n\nc\n\n\nd",
  "\n\n\na\n\nb\n",
  "a\n\n",
  "abc\n\n\n",
  "a\r\nb\r\n\r\nc\r\n",
  "abXcdXX\r\nef\r\n\r\nghi\n\n\nj",
  "日本語\n日本\n\nx",
  "x",
  ""
]

CONTENTS.each_with_index do |c, i|
  puts "--- #{i} #{c.inspect}"
  p StringIO.new(c).gets
  p StringIO.new(c).gets("")
  p StringIO.new(c).gets("", chomp: true)
  p StringIO.new(c).gets(chomp: true)
  p StringIO.new(c).gets(nil)
  p StringIO.new(c).gets(nil, 4)
  p StringIO.new(c).gets(3)
  p StringIO.new(c).gets(4)
  p StringIO.new(c).gets("X")
  p StringIO.new(c).gets("X", chomp: true)
  p StringIO.new(c).gets("X", 1)
  p StringIO.new(c).gets(0)
  p StringIO.new(c).gets(-1)
  p StringIO.new(c).gets("", 2)
  p lines(StringIO.new(c)) { |io| io.gets }
  p lines(StringIO.new(c)) { |io| io.gets("") }
  p lines(StringIO.new(c)) { |io| io.gets("", chomp: true) }
  p lines(StringIO.new(c)) { |io| io.gets(chomp: true) }
  p lines(StringIO.new(c)) { |io| io.gets(3) }
  p lines(StringIO.new(c)) { |io| io.gets("X", 2) }
  p StringIO.new(c).readlines
  p StringIO.new(c).readlines("")
  p StringIO.new(c).readlines("", chomp: true)
  p StringIO.new(c).readlines(chomp: true)
  p StringIO.new(c).readlines(nil)
  p StringIO.new(c).readlines("X")
  p StringIO.new(c).readlines("X", chomp: true)
  p StringIO.new(c).readlines(4)
  p StringIO.new(c).readlines(nil, 3)
  p StringIO.new(c).readlines("X", 2)
  tried { StringIO.new(c).readlines(0) }
  tried { StringIO.new(c).readline }
  tried { StringIO.new(c).readline("") }
  tried { StringIO.new(c).readline("", chomp: true) }
  tried { StringIO.new(c).readline(chomp: true) }
  tried { StringIO.new(c).readline(nil) }
  tried { StringIO.new(c).readline(2) }
  tried { StringIO.new(c).readline("X", 3) }
  io = StringIO.new(c)
  io.gets("")
  io.gets(chomp: true)
  p io.lineno
  io = StringIO.new(c)
  io.readlines("")
  p io.lineno
  a = []; StringIO.new(c).each_line("") { |l| a << l }; p a
  a = []; StringIO.new(c).each_line(chomp: true) { |l| a << l }; p a
  a = []; StringIO.new(c).each_line("X") { |l| a << l }; p a
  a = []; StringIO.new(c).each_line("", chomp: true) { |l| a << l }; p a
  a = []; StringIO.new(c).each_line(3) { |l| a << l }; p a
  a = []; StringIO.new(c).each_line(nil) { |l| a << l }; p a
  a = []; StringIO.new(c).each_line("X", 2, chomp: true) { |l| a << l }; p a
  a = []; StringIO.new(c).each(chomp: true) { |l| a << l }; p a
  a = []; StringIO.new(c).each("") { |l| a << l }; p a
end

# arguments that are not a separator or a limit
c = "abc\ndef\n"
tried { StringIO.new(c).gets(:a) }
tried { StringIO.new(c).gets(1.5) }
tried { StringIO.new(c).gets(true) }
tried { StringIO.new(c).gets("x", "y") }
tried { StringIO.new(c).gets("x", 1.5) }
tried { StringIO.new(c).gets(:a, 2) }
tried { StringIO.new(c).gets("\n", 2, 3) }
tried { StringIO.new(c).gets(chomp: nil) }
tried { StringIO.new(c).gets(chomp: 1) }
tried { StringIO.new(c).gets(foo: 1) }
tried { StringIO.new(c).gets(chomp: true, foo: 1) }
tried { StringIO.new(c).readlines(:a) }
tried { StringIO.new(c).each_line(0) { |l| l } }
tried { StringIO.new(c).each_line("\n", 0) { |l| l } }

# where the position lands, and a multibyte limit
tried { io = StringIO.new("ab\ncd\nef"); io.gets; io.pos }
tried { io = StringIO.new("ab\n\n\ncd"); io.gets(""); io.pos }
tried { io = StringIO.new("\n\n"); [io.gets(""), io.eof?, io.pos] }
tried { io = StringIO.new("日本語"); [io.gets(1), io.pos] }
tried { io = StringIO.new("日本語"); [io.gets(2), io.gets(2), io.gets(2)] }
tried { StringIO.new("ab--cd----ef").readlines("--", chomp: true) }
tried { StringIO.new("ab--cd----ef").gets("--", 3) }
tried { StringIO.new("a\rXb").gets("X", chomp: true) }
tried { StringIO.new("ab\r\n").gets(nil, chomp: true) }

# a limit and a separator held in variables
n = 2
sep = "e"
lim = nil
tried { StringIO.new(c).gets(n) }
tried { StringIO.new(c).gets(sep) }
tried { StringIO.new(c).gets("\n", lim) }
tried { StringIO.new(c).gets(lim) }

# a splat of arguments reads as the arguments
args = []
tried { StringIO.new("ab\ncd\n").readlines(*args) }
tried { StringIO.new("ab\ncd\n").readline(*args) }
tried { StringIO.new("abcd\nef\n").readlines(*[2]) }
def lines_of(io, *args) = io.readlines(*args)
tried { lines_of(StringIO.new("ab\ncd\n")) }
tried { lines_of(StringIO.new("abXcd"), "X") }
tried { lines_of(StringIO.new("abXcd"), "X", 1) }
tried { StringIO.new("ab\n").readlines(*[1, 2, 3]) }

# each_line and each answer the StringIO, and a block that rebinds the
# variable passed in does not change the loop
io = StringIO.new("ab\ncd\n")
tried { io.each_line { |l| l }.equal?(io) }
tried { io.rewind; io.each { |l| l }.equal?(io) }
s = "b"
r = []
StringIO.new("abcbd\nxb\n").each_line(s) { |l| r << l; s = "x" }
p r
n = 2
r = []
StringIO.new("abcdef").each_line(n) { |l| r << l; n = 1 }
p r
tried { r = []; StringIO.new("abcd\nef").each_line(1.9) { |l| r << l }; r }

# a block that changes the separator String in place (the loop sees it here
# because the program also calls each_line with an Integer or a Float)
u = +"b"
r = []
StringIO.new("abcbdbd\nxbd\n").each_line(u) { |l| r << l; u << "d" }
p [r, u]

# a String changed in place and held in a container is the separator's text
mu = +"X"
mu << "X"
arm = [mu, 3, nil]
r = []
StringIO.new("abXcdXXef\ngh").each_line(arm[0]) { |l| r << l }
p r
tried { StringIO.new("abXcdXXef\ngh").gets(arm[0]) }
tried { StringIO.new("abXcdXXef\ngh").readlines(arm[0], chomp: true) }
tried { StringIO.new("abXcdXXef\ngh").readline(arm[0], 4) }

# a Float limit is truncated first: a fraction below one is a zero limit
tried { StringIO.new("a\nb").each_line("\n", 0.5) { |l| l } }
tried { StringIO.new("a\nb").each_line(-0.5) { |l| l } }
tried { r = []; StringIO.new("abcd").each_line("\n", 2.5) { |l| r << l }; r }
tried { StringIO.new("a\nb\n").readlines(nil, chomp: true) }
tried { io = StringIO.new("abcd\n"); [io.readline(2, chomp: true), io.readline(chomp: true)] }

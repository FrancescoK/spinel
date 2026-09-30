# `each_line`, `gets`, `readlines` and `foreach` on a File: `chomp: true`
# takes "\r\n" as well as "\n" and reaches the block form of `each_line`, an
# empty separator reads paragraphs (blank lines between them are dropped,
# and a paragraph ends with exactly one blank line), and the separator, the
# limit and `chomp:` are evaluated once, ahead of the loop.
path = "/tmp/spinel_io_lines_chomp_paragraph_#{Process.pid}.txt"

CONTENTS = [
  "a\nb\n\nc\n\n\nd",
  "\n\n\na\n\nb\n",
  "a\n\n\n\n",
  "a\r\nb\r\n\r\nc\r\n",
  "\n\n\n",
  "",
  "x",
  "para one\nline two\n\n\n\npara two\n"
]

CONTENTS.each_with_index do |c, i|
  File.write(path, c)
  puts "--- #{i} #{c.inspect}"
  File.open(path) { |f| p f.gets("") }
  File.open(path) { |f| p f.gets("", chomp: true) }
  File.open(path) { |f| a = []; while (l = f.gets("")); a << l; end; p a }
  File.open(path) { |f| a = []; while (l = f.gets("", chomp: true)); a << l; end; p a }
  File.open(path) { |f| p f.readlines("") }
  File.open(path) { |f| p f.readlines("", chomp: true) }
  p File.readlines(path, "")
  p File.readlines(path, "", chomp: true)
  a = []; File.foreach(path, "") { |l| a << l }; p a
  a = []; File.foreach(path, "", chomp: true) { |l| a << l }; p a
  a = []; File.open(path) { |f| f.each_line("") { |l| a << l } }; p a
  a = []; File.open(path) { |f| f.each_line("", chomp: true) { |l| a << l } }; p a
  a = []; File.open(path) { |f| f.each_line(chomp: true) { |l| a << l } }; p a
  a = []; File.open(path) { |f| f.each_line { |l| a << l } }; p a
  File.open(path) { |f| p f.gets(chomp: true) }
  File.open(path) { |f| a = []; while (l = f.gets(chomp: true)); a << l; end; p a }
  File.open(path) { |f| p f.readlines(chomp: true) }
  File.open(path) { |f| p f.readline(chomp: true) } rescue p $!.class
end

File.write(path, "abXcdXX\r\nef\r\n\r\nghi\n\n\nj")
File.open(path) { |f| p f.gets("X", chomp: true) }
File.open(path) { |f| p f.gets(nil, 4) }
File.open(path) { |f| a = []; f.each_line("X", chomp: true) { |l| a << l }; p a }
File.open(path) { |f| a = []; f.each_line(nil) { |l| a << l }; p a }
File.open(path) { |f| a = []; f.each_line(4) { |l| a << l }; p a }
File.open(path) { |f| a = []; f.each_line("X", 3) { |l| a << l }; p a }
File.open(path) { |f| a = []; f.each_line(chomp: false) { |l| a << l }; p a }
flag = true
File.open(path) { |f| a = []; f.each_line(chomp: flag) { |l| a << l }; p a }

# the arguments run once, not once per line
n = 0
sep = -> { n += 1; "" }
File.open(path) { |f| a = []; f.each_line(sep.call, chomp: n > 0) { |l| a << l }; p [a, n] }
File.open(path) { |f| f.each_line(chomp: true) { |l| break }; p f.lineno }
File.open(path) { |f| f.each_line { |l| }; p f.lineno }

File.open(path) do |f|
  p f.readline("")
  p f.readline("", chomp: true)
  p((f.readline("") rescue $!.class))
end
IO.foreach(path, "") { |l| p l }

# a separator that starts with a NUL byte is not the empty one
File.write(path, "a\n\nb")
File.open(path) { |f| p f.gets("\0") }
File.open(path) { |f| p f.gets(["\0"].join) }
File.write(path, "\n")
File.open(path) { |f| p f.readlines("\0") }
File.open(path) { |f| a = []; f.each_line("\0") { |l| a << l }; p a }

# an empty separator built at run time is paragraph mode; a nil one held in a
# value of several types still reads to the end
File.write(path, "a\n\n\nb\n\n\n\nc")
File.open(path) { |f| a = []; f.each_line([""].join) { |l| a << l }; p a }
opts = {sep: nil, empty: "", lim: 100, name: "x"}
File.open(path) { |f| p f.gets(opts[:sep]) }
File.open(path) { |f| p f.gets(opts[:sep], chomp: true) }
File.open(path) { |f| p f.gets(opts[:empty]) }

# a limit held in a value of several types is left alone, as it was
File.open(path) { |f| a = []; f.each_line(opts[:lim]) { |l| a << l }; p a }
File.open(path) { |f| a = []; f.each_line("\n", opts[:lim]) { |l| a << l }; p a }

# paragraph mode with a limit
File.open(path) { |f| a = []; while (l = f.gets("", 3)); a << l; end; p a }
File.open(path) { |f| a = []; f.each_line("", 3) { |l| a << l }; p a }
File.open(path) { |f| a = []; f.each_line("", 3, chomp: true) { |l| a << l }; p a }

# a limit that cuts a read at the last byte of the separator
File.write(path, "\n\n\n")
File.open(path) { |f| a = []; f.each_line("\r\n", 1) { |l| a << l }; p a }
File.open(path) { |f| a = []; f.each_line("\r\n", 2) { |l| a << l }; p a }
File.open(path) { |f| a = []; while (l = f.gets("\r\n", 1)); a << l; end; p a }
File.write(path, "a\nb\n")
File.open(path) { |f| a = []; f.each_line("\r\n", 1) { |l| a << l }; p a }
File.write(path, "x\nx\n")
File.open(path) { |f| a = []; f.each_line("x\n", 1) { |l| a << l }; p a }
File.write(path, "é\nü\n\nñ\n\n\n日本語\n")
File.open(path) { |f| a = []; f.each_line("\r\n", 3) { |l| a << l }; p a }

# a nil limit after the separator is no limit, and a limit that falls inside a
# character reads on to the end of it
File.write(path, "ab3de\nfg\n\nh3\n")
File.open(path) { |f| a = []; f.each_line("\n", nil) { |l| a << l }; p a }
File.open(path) { |f| a = []; f.each_line("3", nil) { |l| a << l }; p a }
File.write(path, "ñ")
File.open(path) { |f| a = []; f.each_line(1) { |l| a << l }; p a }
File.write(path, "a日")
File.open(path) { |f| a = []; f.each_line("\n", 2) { |l| a << l }; p a }
File.open(path) { |f| a = []; while (l = f.gets(3)); a << l; end; p a }
File.write(path, "日本語\n")
File.open(path) { |f| a = []; while (l = f.gets(2)); a << l; end; p a }
File.open(path) { |f| p f.readline(1) }

# a lead byte that starts no character, or a second byte its lead does not allow,
# is invalid at once: the limit does not wait for more
def cut_at(path, bytes, lim)
  File.binwrite(path, bytes)
  File.open(path) { |f| a = []; while (l = f.gets(lim)); a << l; end; p a }
  File.open(path) { |f| a = []; f.each_line(lim) { |l| a << l }; p a }
end
cut_at(path, "\xC0\x80", 1)
cut_at(path, "\xE0\x80\x80", 2)
cut_at(path, "\xED\xA0\x80", 2)
cut_at(path, "\xF4\x90\x80\x80", 2)
cut_at(path, "a\xFFb", 2)
cut_at(path, "\xFF\xFF\xFF", 1)
cut_at(path, "\xF0\x80\x80\x80", 2)

# a separator that would start on a continuation byte is not matched there, whatever
# precedes the byte, and chomp takes off only a separator that was matched
File.binwrite(path, "a\xA5\xA9b")
File.open(path) { |f| a = []; f.each_line("é", 3, chomp: true) { |l| a << l }; p a }
File.open(path) { |f| a = []; f.each_line("é", 3) { |l| a << l }; p a }
File.binwrite(path, "a\x80")
File.open(path) { |f| a = []; f.each_line("\x80", chomp: true) { |l| a << l }; p a }

# chomp leaves the "\r" of a last line that has no "\n"
File.write(path, "a\r")
File.open(path) { |f| p f.gets(chomp: true) }
File.write(path, "a\r\nb\r")
File.open(path) { |f| a = []; while (l = f.gets(chomp: true)); a << l; end; p a }

# the limit and `chomp:` run once too
File.write(path, "a\r\nb\r\n")
n = 0
lim = -> { n += 1; 100 }
File.open(path) { |f| a = []; f.each_line("\n", lim.call, chomp: n > 0) { |l| a << l }; p [a, n] }

File.delete(path)

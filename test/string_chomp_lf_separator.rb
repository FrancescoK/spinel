# String#chomp("\n") is the record separator's own case: it removes one
# trailing "\r\n", "\n" or "\r".
p "abc\r\r".chomp("\n")
p "abc\r\n\r\n".chomp("\n")
p "abc\r\n".chomp("\n")
p "abc\n".chomp("\n")
p "abc\r".chomp("\n")
p "abc\n\n".chomp("\n")
p "abc".chomp("\n")
p "".chomp("\n")
p "\r\n".chomp("\n")
p "é\r\n".chomp("\n")
sep = "\n"
p "abc\r\r".chomp(sep)
s = ["abc\r\r", 1][0]
p s.chomp("\n")
t = String.new("abc\r\n")
p t.chomp!("\n"), t
u = String.new("abc\r")
p u.chomp!("\n"), u
v = String.new("abc")
p v.chomp!("\n"), v

# the record separator itself, an LFCR ending, a NUL in the receiver, a separator from
# a method
p "abc\r\n".chomp($/)
p "abc\n\r".chomp("\n")
p "a\0b\r\n".chomp("\n")
def lf = "\n"
p "abc\r\n".chomp(lf)
p "x\r\ny\r\n".lines.map { |l| l.chomp("\n") }

# other separators are matched exactly, the paragraph mode and nil as before
p "abc\r\n".chomp("\r\n")
p "abc\n".chomp("\r\n")
p "abc\r\n".chomp("\r")
p "abc\r".chomp("\r")
p "abc\r\n".chomp("\n\n")
p "abc\n".chomp("c\n")
p "abc\r\n".chomp("")
p "abc\r\r".chomp
p "abc\n".chomp(nil)

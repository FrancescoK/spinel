# `=~` with a Regexp that may be nil (a boxed operand) answers a character
# position, as the typed form does: it answered the byte offset, 3 for "b"
# in "é\nb". A BINARY subject's positions are its bytes, typed or boxed.
re = ARGV.size > 5 ? nil : /b/
s = "é\nb"
p(s =~ re)
p(re =~ s)
p $~.begin(0)
p(s !~ re)
p s.match(re, 1)
p s.match(re, 1).begin(0)
p s.match?(re, 2)
p s.match(re)

# from a method that may answer nil
def pick(f) = f ? /c/ : nil
r = pick(ARGV.empty?)
p("日本語c" =~ r)
p(r =~ "日本語c")
p("abc" =~ r)

# no match, and a nil Regexp
p("日本" =~ r)
n = ARGV.empty? ? nil : /x/
p("é" =~ n)

# BINARY subjects count bytes
b = "é\nb".b
p(b =~ /b/)
p(b =~ re)
p(re =~ b)

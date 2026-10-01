# A shared String handle pushed into a typed String array, then appended to
# until its buffer moves: the array must not keep the old buffer (a GC scan
# of it crashed). Only what CRuby and Spinel agree on is printed: Spinel's
# typed array keeps a copy, where CRuby shares the String.
def app(x) = x << "!"
def addv(x, m) = x << m[ARGV.size]
m = [+"ab", 1]
app(m[0])
s = ["x"]
p addv(s, m).size
30.times { app(m[0]) }
GC.start
40.times { s << +"pad" }
GC.start
p s.size, s[0], m[0].size

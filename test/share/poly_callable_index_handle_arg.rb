# A boxed Proc or Method called through [] with two arguments gets a
# shared String argument as the String itself, as .call does: the second
# argument was read as a copy of its bytes, so a mutation through it
# missed the caller's String and equal? answered false. A Regexp's named
# capture still takes a String name the same way.
s = +"ab"
v = [s, 1].first
pr = [proc { |x, y| y << "!"; y.equal?(x) }, 1].first
p pr[v, v], s
def m(x, y) = (y << "?"; x.equal?(y))
mm = [method(:m), 1].first
p mm[v, v], s
t = [+"hello world", 1].first
re = [/(?<w>o\s)/, 1].first
p t[re, [+"w", 1].first], t[re, :w]

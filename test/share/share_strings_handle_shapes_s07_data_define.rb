# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
D = Data.define(:a, :b)
c = ARGV.size == 0
s = +"abc"
d = D.new(a: (c ? s : +"q"), b: s.then { |q| q })
d.a << "!"
p s, d.a.equal?(s), d.b.equal?(s)

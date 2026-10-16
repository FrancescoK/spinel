# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def pair(s, c)
  x, y = (c ? s : +"q"), s.then { |q| q }
  [x, y]
end
s = +"abc"
a, b = pair(s, ARGV.size == 0)
a << "!"
b << "?"
p s, a.equal?(s), b.equal?(s)

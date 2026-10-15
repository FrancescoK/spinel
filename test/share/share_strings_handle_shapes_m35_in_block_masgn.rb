# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
out = []
[1, 2].each do |i|
  x, y = (c ? s : +"q"), i
  x << i.to_s
  out << x
end
p s, out, out[0].equal?(s)

# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
keep = []
50.times do |i|
  t = +"t#{i}"
  x, y, z = (c ? t : s), (i.to_s * 300), (c ? t : s)
  keep << x
  x << "!" if i == 3
  p [x, z.equal?(x)] if i == 3
end
p keep[3], keep.size

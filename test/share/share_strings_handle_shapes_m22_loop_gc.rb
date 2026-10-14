# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
t = +"zz"
acc = []
200.times do |i|
  x, y, z = (c ? s : t), ("a" * (i + 50)), (c ? s : t).then { |q| q }
  acc << x << z
  x << "." if i % 50 == 0
end
p s, acc.size, acc.all? { |e| e.equal?(s) }, acc.last

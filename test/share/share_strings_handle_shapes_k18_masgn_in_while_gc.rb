# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
i = 0
keep = []
while i < 300
  x, y = (c ? s : +"q"), (+"n" << i.to_s)
  keep << y if i % 7 == 0
  i += 1
end
x << "!"
p s, keep.size, keep.last, x.equal?(s)

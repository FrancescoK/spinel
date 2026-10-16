# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
k = ARGV.size
s = +"abc"
x, y = (case k when 0 then s else +"o" end), (k == 0 ? s : nil)
x << "!"
p s, x, y, x.equal?(s), y.equal?(s)

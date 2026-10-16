# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
x = nil
[1].each { |i| x, y = (c ? s : +"q"), i }
x << "!"
p s, x.equal?(s)

# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
r = if c then x, y = (c ? s : +"q"), 1 else nil end
x << "!"
p s, x.equal?(s)

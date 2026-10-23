# The two String representations refused this program; with one it answers as CRuby.
# Flag-only: under --share-strings, a multiple write at the top level into
# instance variables that a later `<<` types as Arrays (the default build
# fails to build it too) cannot store the handle of a String that is shared
# with another name: refused, not a C error, though the multiple write before
# it, which stores a conditional, is carried.
s = +"abc"
c = ARGV.size == 0
x, y = s, (c ? s : +"n")
x << "!"
y << "?"
@a, @b = (1; s), s.itself
@a << "#"
@b << "%"
p s, x.equal?(y)

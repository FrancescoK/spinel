# The two String representations refused this program; with one it answers as CRuby.
# Flag-only: under --share-strings, a multiple write with a nested target
# builds the nested literal ahead of its other values, so a value of it that
# changes a shared String and is answered as the handle would run after the
# literal's own change: refused.
s = +"abc"
x, (y, z) = s.upcase!, [s.upcase!, +"i"]
x << "!"
p s, x, y

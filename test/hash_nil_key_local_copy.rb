# A Hash local keyed by an Integer that can be nil, copied into another local
# (`h = seen`) that is read afterwards. A write of the Hash into a local typed
# as the Hash is was taken to hand it on whole, so the Hash stayed typed and
# the nil key was refused at run time (a TypeError) where CRuby stores it. The
# copy is retyped with the Hash when it hands nothing on itself.
b = [5, 6][ARGV.size + 7]
seen = {}
[3, b].each_with_index { |x, i| seen[x] = i }
p seen
h = seen
p h
h[9] = 2
p seen.keys

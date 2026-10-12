# --share-strings: a multiple write stores each element of the Array
# literal it splits into its target, also through a splat: each target
# holds the String the literal names, and a change through it reaches
# the other names (the run-time answers of test/share_check/store.rb's
# local stores).
# spinel: gc-stress
s = +"s"; t = +"t"; u = +"u"
a, b = *[s, t]
a << "?"
x, y = s, *[t, u]
y << "&"
p [s, t, a, b, x, y, a.equal?(s), y.equal?(t)]

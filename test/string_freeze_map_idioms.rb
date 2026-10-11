# freeze in the common container idioms: a map's block or a Symbol block
# freezing each element, a constant of frozen names, a Hash value or key
# frozen as it is stored. Each answers the receiver itself, frozen.
a = %w[x y].map(&:freeze)
p a, a[0].frozen?
b = [+"x"].map { |x| x.freeze }
p b, b[0].frozen?
NAMES = %w[a b].map(&:freeze)
p NAMES, NAMES[1].frozen?
h = {}
k = +"k"
h[:z] = (+k).freeze
p h, h[:z].frozen?, k.frozen?
g = {}
g[k] = k.freeze
p g, k.frozen?
x = +"x"
m = [x].map(&:freeze)
p m, x.frozen?, m[0].equal?(x)

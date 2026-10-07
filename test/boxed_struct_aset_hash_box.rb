# A store into a box that holds only Hashes reaches no Struct's `[]=`, so
# it types no member: the member keeps the String it was built with, and
# the String's in-place change reads back through it (a member typed for
# a value that never reaches it holds a copy).
S = Struct.new(:x)
s = +"abc"
o = S.new(s)
s << "d"
p o.x
o.x << "e"
p s
q = [{x: 1}, 2][0]
q[:x] = 4
k = [:x, :y][ARGV.size]
q[k] = 4.5
p q

# Flag-only: a String member a store of another class reaches through a box,
# or by a key no literal names, is boxed, and under --share-strings a boxed
# member the rule shares holds each String stored into it as its handle: by
# its construction, its writer (through a box too) and `[]=`. The member
# then answers what was stored, and a String's in-place change shows
# through each of its names. (The default build keeps such a member a
# String and raises TypeError for the other value.)
S = Struct.new(:x)
o = [S.new("value"), 0][0]
o[0] = 4
p o.x
o[:x] = [1]
p o.x

# constructed from a fresh String, then changed through the member
def pick(i)
  i > 0 ? [S.new(+"q"), 1] : {0 => 2}
end
pick(ARGV.size)[0] = 5 if ARGV.size > 3
m = S.new(String.new("xy"))
m.x << "z"
p m.x

# a variable's String, changed through the variable
s = +"abc"
n = S.new(s)
s << "d"
p n.x

# the writer, typed and through a box
T = Struct.new(:y)
a = T.new(1)
a.y = String.new("pq")
a.y << "r"
p a.y
b = [T.new(1), 0][0]
b.y = String.new("uv")
b.y << "w"
p b.y

# `[]=` by a computed key on a receiver typed as the Struct
U = Struct.new(:a, :b)
k = ARGV.size
u = U.new(+"m", 2)
t = +"n"
u[k] = t
t << "!"
u[k + 1] = 3
p u

# a variable's String through a box's writer, changed through either name
o2 = [S.new(+"value"), 0][0]
o2.x = 4
s2 = +"abc"
o2.x = s2
s2 << "d"
p o2.x
o2.x << "e"
p s2

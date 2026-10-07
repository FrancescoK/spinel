# A Struct member holds any object, whatever `[]=` stores into it. A store
# through a boxed receiver, or by a key no literal names, now types the
# member by the value as `o.x = v` does: it unboxed the value as the type
# the construction gave the member (an Integer read as a String pointer,
# a String's address printed as the Integer).
S = Struct.new(:x)
T = Struct.new(:x, :y)

# through a box bound from an Array literal's element: each value kind
# into a member constructed as a String
o = [S.new("value"), 0][0]; o[0] = 4; p o.x, o.x.class
o = [S.new("value"), 0][0]; o[:x] = 4.5; p o.x, o.x.class
o = [S.new("value"), 0][0]; o["x"] = :sym; p o.x, o.x.class
o = [S.new("value"), 0][0]; o[:x] = true; p o.x, o.x.class
o = [S.new("value"), 0][0]; o[:x] = [1]; p o.x, o.x.class
o = [S.new("value"), 0][0]; o[:x] = {a: 1}; p o.x, o.x.class
o = [S.new("value"), 0][0]; o[-1] = nil; p o.x, o.x.class

# a String into a member constructed as an Integer, through a Hash
# literal's value
h = {a: S.new(1), b: 2}[:a]
h[:x] = +"z"
p h.x, h.x.class

# a box that can hold either of two Structs
b = [S.new("value"), T.new(1, 2)][0]
b[:x] = 4
p b
b = [S.new("value"), T.new(1, 2)][1]
b[0] = "s"
b[:y] = 2.5
p b

# through a parameter both Structs reach
def put(r, v)
  r[:x] = v
  r
end
p put(S.new(1), "z"), put(T.new("a", 1), 3)

# a receiver typed as the Struct, by a key no literal names
k = [0, :x][ARGV.size]
t = T.new("value", 1)
t[k] = 4
t[k.succ] = 4.5
p t, t.x + 1
t[k] = nil
p t
p(t[k] = nil)
v = (t[k + 1] = nil)
p v, t
n = T.new(1, 2)
p(n[k] = nil)
p n


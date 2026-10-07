# A Struct member holds any object, whatever `[]=` stores into it. A store
# through a boxed receiver, or by a key no literal names, now types the
# member by the value as `o.x = v` does: it unboxed the value as the type
# the construction gave the member (an Integer read as a String pointer,
# a String's address printed as the Integer). A String member is the one
# such a store does not retype (test/boxed_struct_aset_hash_box.rb).
S = Struct.new(:x)
T = Struct.new(:x, :y)

# through a box bound from an Array literal's element: each value kind
# into a member constructed as a Symbol
o = [S.new(:value), 0][0]; o[0] = 4; p o.x, o.x.class
o = [S.new(:value), 0][0]; o[:x] = 4.5; p o.x, o.x.class
o = [S.new(:value), 0][0]; o["x"] = "str"; p o.x, o.x.class
o = [S.new(:value), 0][0]; o[:x] = true; p o.x, o.x.class
o = [S.new(:value), 0][0]; o[:x] = [1]; p o.x, o.x.class
o = [S.new(:value), 0][0]; o[:x] = {a: 1}; p o.x, o.x.class
o = [S.new(:value), 0][0]; o[-1] = nil; p o.x, o.x.class

# a String into a member constructed as an Integer, through a Hash
# literal's value
h = {a: S.new(1), b: 2}[:a]
h[:x] = +"z"
p h.x, h.x.class

# a box that can hold either of two Structs
b = [S.new(:value), T.new(1, 2)][0]
b[:x] = 4
p b
b = [S.new(:value), T.new(1, 2)][1]
b[0] = "s"
b[:y] = 2.5
p b

# through a parameter both Structs reach
def put(r, v)
  r[:x] = v
  r
end
p put(S.new(1), "z"), put(T.new(:a, 1), 3)

# a receiver typed as the Struct, by a key no literal names
k = [0, :x][ARGV.size]
t = T.new(:value, 1)
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


# a multiple assignment and an operator assignment through a box, or by a
# key no literal names, store as `[]=` does
U = Struct.new(:x, :y)
def lit(v) = (puts "v#{v}"; v)
m = [U.new(:value, :w), 0][0]
m[lit(0)], m[:y] = lit(4), lit(5.5)
p m, m.x + 1
m[0], m[1] = 7
p m
w = U.new(:a, 1)
w[k], w[k + 1] = "s", 2.5
p w
e = [U.new(1.5, nil), 0][0]
e[:y] ||= 4
e[1] += 1
e[:x] += 1
p e
w[k] += "!"
w[k + 1] *= 2
p w

# a Data has no `[]=`
D = Data.define(:x)
d = D.new(x: "s")
begin
  d[k] = 4
rescue NoMethodError => ex
  p ex.message
end
p d

# nil through a box whose classes the analysis cannot tell, into members
# that have no nil of their own
F = Struct.new(:flag, :sym, :n)
def pick(i, s) = i > 0 ? s : [1, 2]
f = pick(1, F.new(true, :a, 3))
f[0] = nil
f[1] = nil
f[:n] = nil
p f
f[0] = false
f[:sym] = :b
p f

# a multiple assignment by literal keys on a receiver typed as the Struct
g = T.new(1, 2)
g[:x], g[1] = 8, 9
p g

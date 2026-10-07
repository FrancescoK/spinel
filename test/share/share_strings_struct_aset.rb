# Flag-only: a String held as the shared handle, stored into a Struct
# member by `[]=` through a boxed receiver or by a key that is no literal,
# is stored as the handle, and the member boxed to hold it: a change
# through the variable or through the member reaches the other, as one
# object's does in CRuby. (The default build stores a copy.)
S = Struct.new(:x, :y)

# through a box bound from an Array literal's element
o = [S.new(+"value", 1), 0][0]
o[0] = 4
s = +"abc"
o[0] = s
s << "d"
p o.x
o.x << "e"
p s

# by a computed key, on a receiver typed as the Struct
t = S.new(+"value", 1)
k = ARGV.size
s2 = +"abc"
t[k] = s2
t[k + 1] = 5
s2 << "d"
p t

# changed before the store, or with only another member read after
s3 = +"abc"
s3 << "d"
u = S.new(+"a", 1)
u[k] = s3
u[k + 1] = 5
p u
s4 = +"abc"
w = S.new(+"a", 1)
w[k] = s4
w[k + 1] = 5
s4 << "d"
p s4, w.y

# an ivar's String, through a method's parameter
class H
  def initialize; @s = +"abc"; end
  def go(o, k)
    o[k] = @s
    @s << "d"
    o
  end
end
p H.new.go(S.new(+"a", 1), k)

# a box of three Structs, one without the member the key names
T = Struct.new(:x, :n)
U = Struct.new(:z, :w)
b = [T.new(1, 2), S.new(1, 2), U.new(1, 2)][k]
s5 = +"abc"
b[k] = s5
s5 << "d"
p b

# a Struct with an Integer member, through a box
i = [S.new(4, 1), 0][0]
s6 = +"abc"
i[0] = s6
s6 << "d"
p i.x

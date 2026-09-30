# String#squeeze with an empty character set squeezes nothing: the set
# matches no character.
p "aabb".squeeze("")
p "aabb  cc".squeeze("")
p "".squeeze("")
p "ééàà".squeeze("")
e = ""
p "aabb".squeeze(e)
s = ["aabb", 1][0]
p s.squeeze("")
t = String.new("aabb")
p t.squeeze!("")
p t

# with more than one set, and the neighbouring cases
p "aabb".squeeze("", "a")
p "aabb".squeeze("a", "")
p "aabb".squeeze("a")
p "aabb".squeeze("^a")
p "aa^^".squeeze("^")
p "aabb".squeeze
u = String.new("aabb")
p u.squeeze!
p u

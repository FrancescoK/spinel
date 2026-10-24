# The block parameters of sort / sort! with a block over a String Array are
# the elements themselves: a change through one (`a << "!"`) reaches the
# String in the Array and every other name for it. They were bound to the
# elements' bytes, and the change went to a copy.
s = +"abc"
r = [s, +"q"].sort { |a, b| a << "!"; a <=> b }
p s, r
t = +"zz"
w = [+"b", t, +"a"]
w.sort! { |x, y| y <=> x }
p w
w.sort! { |x, y| x.equal?(t) ? x.upcase! : nil; x <=> y }
p t
v = %w[d c b a].sort { |x, y| x <=> y }
p v

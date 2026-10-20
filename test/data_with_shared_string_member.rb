# Data#with into a member that holds a shared String (one another name
# changes in place) takes the given value's String itself: a new String
# from pack, a literal, or a variable's String.

Section = Data.define(:name, :data)

buf = +"abc"
s = Section.new(name: "x", data: buf)
buf << "!"
t = s.with(data: [65, 66].pack("C*"))
u = s.with(name: "y")
other = +"def"
v = s.with(data: other)
other << "?"
p s.data, t.data, u.data, v.data
p s.data.equal?(buf), u.data.equal?(buf), v.data.equal?(other), t.name, u.name

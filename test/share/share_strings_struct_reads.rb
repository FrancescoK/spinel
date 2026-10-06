# Flag-only: without the flag (as on master) a member read by key or through
# Enumerable is a copy, and a change through it misses the member.
# A Struct member read by a literal key ([] with an offset, a negative
# offset, a Symbol or a String; dig with a Symbol or an offset) or through
# Struct#each (entries, to_a, first, min, max, minmax, sort, zip, each_slice,
# map, inject) answers the member's String itself, as CRuby does.
S = Struct.new(:a, :b)

e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s[0]
t << "!"
p [:idx, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s[-1]
t << "!"
p [:neg, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s[:a]
t << "!"
p [:sym, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s["b"]
t << "!"
p [:str, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.dig(:a)
t << "!"
p [:dig_sym, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.dig(1)
t << "!"
p [:dig_int, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.entries[0]
t << "!"
p [:entries, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.to_a[1]
t << "!"
p [:to_a, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.first
t << "!"
p [:first, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.min
t << "!"
p [:min, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.max
t << "!"
p [:max, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.minmax[1]
t << "!"
p [:minmax, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.sort[0]
t << "!"
p [:sort, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.zip([1, 2])[0][0]
t << "!"
p [:zip, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.each_slice(1).to_a[1][0]
t << "!"
p [:each_slice, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.map { |m| m }[0]
t << "!"
p [:map, e0, e1, t.equal?(e0) || t.equal?(e1)]
e0 = +"e0"; e1 = +"e1"; s = S.new(e0, e1)
t = s.inject { |m, _| m }
t << "!"
p [:inject, e0, e1, t.equal?(e0) || t.equal?(e1)]

# a change of the member shows through a read taken before it
e0 = +"x0"
s = S.new(e0, +"x1")
r = s[:a]
e0 << "~"
p [r, r.equal?(e0)]

# a writer's value is its argument, and a read after it the same String
a0 = +"a0"
s = S.new(+"e0", +"e1")
w = (s.a = a0)
w << "!"
x = (s[1] = a0)
x << "?"
y = (s[:b] = a0; s.b)
y << "#"
p [a0, w.equal?(a0), x.equal?(a0), y.equal?(a0)]

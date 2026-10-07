# Flag-only: the frozen mark travels with the shared handle through `tap`
# and `String()`. `"lit".tap { |x| x }` answers the frozen literal itself,
# so `<<` on it raises FrozenError and `frozen?` says true; `s.tap { |x| x }`
# answers s, so a change through the answer shows in s. `String(t).frozen?`,
# `(+t).frozen?`, `t.tap { }.frozen?` and a conditional over t answer per
# t's own mark, which its read face (a copy) does not carry.
u = "lit".tap { |x| x }
p u.frozen?
begin
  u << "x"
rescue FrozenError => e
  p e.class
end
p u
p "lit".tap { |x| x }.frozen?
begin
  "lit".tap { |x| x } << "y"
rescue FrozenError => e
  p e.class
end
s = +"ab"
v = s.tap { |x| x << "c" }
v << "d"
p s, v.equal?(s)
w = s.tap { |x| x }
w << "e"
p s
f = "fro".tap { |x| x }
g = f
p g.frozen?
t = +"ab"
q = t
q << "c"
p String(t).frozen?
t.freeze
p String(t).frozen?, t.tap { |x| x }.frozen?
k = +"k"
k2 = k
k2 << "!"
p String(k).frozen?, (+k).frozen?
p((k.size > 0 ? k : nil).frozen?)
p((k.size > 9 ? k : nil).frozen?)
k.freeze
p((+k).frozen?)
p String(k).then { |y| y }.frozen?
# A frozen String's read through its handle keeps the mark: `inject` seeded
# with a frozen literal, or with a shared String frozen later, hands back a
# String `<<` refuses.
lit = "aabc"
got = [1].inject(lit) { |m, _v| m }
begin
  got << "x"
rescue FrozenError => e
  p e.class
end
p [lit, got]
fz = +"q"
fz2 = fz
fz2 << "!"
fz.freeze
p [1].inject(fz) { |m, _| m }.frozen?, fz.then { |x| x }.frozen?, fz.dup.frozen?, (+fz).frozen?

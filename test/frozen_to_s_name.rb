# nil.to_s, true.to_s, false.to_s and Module#name answer frozen Strings, as
# in CRuby: frozen? is true, mutating raises, and `+s` copies them
a = nil.to_s
b = true.to_s
c = false.to_s
d = Integer.name
class Foo; end
e = Foo.name
v = [nil, true, false, 1][ARGV.size]
f = v.to_s
w = [true, 1][ARGV.size]
g = w.to_s
p a.frozen?, b.frozen?, c.frozen?, d.frozen?, e.frozen?, f.frozen?, g.frozen?
a = nil.to_s
b = +a
b << "x"
c = true.to_s
d = +c
d.upcase!
g = Integer.name
h = +g
h << "?"
p a, b, c, d, g, h
class Foo; end
o = Foo.new
n = o.class.name
p n, n.frozen?
m = +n
m << "!"
p n, m
begin; Foo.name << "x"; rescue FrozenError => e; p e.class; end
begin; nil.to_s << "x"; rescue FrozenError => e; p e.class; end
s = 5.to_s
s << "0"
p s
3.times { p Foo.name.equal?(Foo.name) }
p "#{nil}x#{true}"

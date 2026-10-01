# A frozen String in a poly slot refuses << and []= as a typed one does:
# a literal is frozen (frozen_string_literal is always on) and so is a
# `.freeze`d String; `+"lit"` is the mutable one (#6328)
v = ["fz".freeze, 1][ARGV.size]
p v.frozen?
begin; v << "!"; p v; rescue FrozenError => e; p e.class; end
w = ["fz", 1][ARGV.size]
begin; w[0] = "X"; p w; rescue FrozenError => e; p e.class; end
s = +"ab"
s.freeze
x = [s, 1][ARGV.size]
begin; x << "!"; p x; rescue FrozenError => e; p e.class; end
y = [+"ok", 1][ARGV.size]
y << "!"
y[0] = "O"
p y

def app(o) = o << "!"
app([1, 2])
begin; p app("lit"); rescue FrozenError => e; p e.class; end
m = method(:app)
begin; p m.call("q".freeze); rescue FrozenError => e; p e.class; end
t = +"ok"
p app(t), t

# a range or start-and-length splice refuses too
z = ["zz".freeze, 1][ARGV.size]
begin; z[0, 1] = "Y"; p z; rescue FrozenError => e; p e.class; end
begin; z[0..0] = "Y"; p z; rescue FrozenError => e; p e.class; end
r = [+"rr", 1][ARGV.size]
r[0, 1] = "R"
p r

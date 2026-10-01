# A local bound to a String method's value that IS its receiver -- to_s,
# to_str, itself, freeze, and the mutators that answer self (insert,
# prepend, replace, clear, reverse!, force_encoding, encode!) -- names the
# receiver's object, as `t = s` and `t = s << x` do. When the receiver is
# a shared handle (#6179) the local held a copy instead, so an append
# through it was lost and equal? said false; `t = +@s` on an ivar handle
# was a copy the same way. A plain local reassigned the frozen literal
# `replace` was given, and the next append raised.

pr = proc { |t| t << "!" }

s = +"ab"
pr.call(s)
x = s.to_s
x << "X"
y = s.itself
y << "Y"
z = s.to_str
z << "Z"
p s, x.equal?(s), y.equal?(s), z.equal?(s)

t = +"cd"
pr.call(t)
i = t.insert(1, "I")
i << "i"
r = t.reverse!
r << "r"
pp = t.prepend("<")
pp << ">"
p t, i.equal?(t), r.equal?(t), pp.equal?(t)

u = +"ef"
pr.call(u)
rp = u.replace("new")
rp << "!"
fe = u.force_encoding("UTF-8")
fe << "?"
en = u.encode!("UTF-8")
en << "~"
p u, rp.equal?(u), fe.equal?(u), en.equal?(u)
cl = u.clear
cl << "c"
p u

f = +"gh"
pr.call(f)
fz = f.freeze
p fz.equal?(f), fz.frozen?
begin; fz << "x"; rescue FrozenError => e; p e.class; end
p f

# through a lambda, a keyword argument and a Method
la = ->(t) { t << "?" }
def kw(x:) = x << "k"
def mm(x) = x << "m"
a = +"la"
la.(a)
kw(x: a)
method(:mm).call(a)
b = a.to_s
b << "!"
p a, b.equal?(a)

# a plain local: replace answers the receiver, not the literal it was given
g = +"ij"
rr = g.replace("kl")
g << "!"
p g, rr

# an ivar holding the handle
class Holder
  def initialize; @s = +"iv"; end
  def run
    t = @s; t << "!"
    u = +@s
    u << "U"
    w = @s.insert(0, "<")
    w << ">"
    p @s, u.equal?(@s), w.equal?(@s)
    fr = @s.freeze
    v = +@s
    v << "V"
    p @s, v, v.equal?(@s), fr.equal?(@s)
  end
end
Holder.new.run

# other classes' to_s and itself are not their receivers' Strings
n = 42
m = n.to_s
m << "x"
q = :sym.to_s
q << "y"
p n, m, q

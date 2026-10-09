# clamp on a boxed receiver answers the receiver or one of its bounds, the
# same object, so a mutation through the answer shows in that String.
def pick(i, s)
  i > 0 ? s : 5
end
s = +"m"
x = pick(ARGV.size + 1, s)
r = x.clamp("a", "z")
p r.equal?(s)
r << "!"
p s
lo = +"a"
y = pick(ARGV.size + 1, +"0")
q = y.clamp(lo, "z")
p q.equal?(lo)
q << "?"
p lo
hi = +"c"
z = pick(ARGV.size + 1, +"zz")
u = z.clamp("a", hi)
u << "+"
p [hi, u.equal?(hi)]
n = pick(0, s).clamp(1, 3)
p n

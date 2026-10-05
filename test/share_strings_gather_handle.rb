# A String bound out of a splat into a parameter the rule shares is held
# for the whole call, as the other arguments are built (run under GC stress
# by share-strings-test).
LONG = "!" * 100
e = []
def g(a = nil, *r, z) = (a << LONG if a.is_a?(String); [r.size, z])
s = +"a"; p g(s, *e, 1), s.size
begin
  g("i".freeze, *e, 2)
rescue FrozenError => x
  p x.class
end
p g(+"b", *[1, 2], 3)

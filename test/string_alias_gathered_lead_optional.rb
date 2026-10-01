# An optional parameter ahead of the first splat takes the shared String
# the argument read first, as a required one does (#6501), unless required
# parameters follow the rest.

LONG = "!" * 10
def seen(s) = s.nil? ? :nil : [s[0], s.size]
def g2(a = nil, b = 1, *r) = (a << LONG if a; seen(a))
xs = [+"y", +"w"]
t = +"T"; o2 = t; o2 << ""; p g2(t, *xs, (t = +"t"; 9)), seen(t), seen(o2)
p g2, g2(nil, *xs)
m = nil; p g2(m, *xs, (m = +"m"; 1)), seen(m)

def g5(a = +"d", b = nil, *r) = (b << LONG if b; a << LONG; [seen(a), seen(b)])
u = +"U"; o3 = u; o3 << ""; q = +"Q"; o4 = q; o4 << ""
p g5(u, q, *xs, (u = +"u"; q = +"q"; 9)), seen(o3), seen(o4)
p g5, g5(+"e")

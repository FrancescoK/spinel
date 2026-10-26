# A push of another kind onto an Array literal with a splat element: the
# literal becomes a general Array, and the splat still spreads its items.
a = [1, 2]
r = 1..2
h = {k: 1}
n = nil
s = ["x"]
f = [1.5]
p [*a].push("s")
p [*a].push("s").size
p([*a] << "s")
p [*a].append("s")
p [*r] << "s"
p [*h] << "s"
p [*n] << "s"
p [*a, *s] << :z
p [0, *a] << :z
p [*f] << "s"
p [*s] << 1
p [*a, 3].push("s", :t)
def wrap(x) = [*x] << "q"
p wrap(a)
p wrap(nil)
p wrap(7)

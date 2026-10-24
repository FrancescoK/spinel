# A String bang through &. whose argument runs code (`s&.slice!(f(1))`):
# the receiver is held and read after the argument, and the bang's
# write-back went to that read, which is no variable, so the program did
# not compile. The bang's change shows through the caller's String.
def f(n) = n
def g(s) = s&.slice!(f(1))
s = +"abc"
p g(s), s
p g(nil)
def k(s) = s&.slice!(f(0), 2)
t = +"wxyz"
p k(t), t
def r(s) = s&.slice!(f(1)..f(2))
u = +"12345"
p r(u), u
def ins(s) = s&.insert(f(0), "<")
v = +"q"
p ins(v), v

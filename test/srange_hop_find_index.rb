# find_index over a String Range whose begin is a parameter or a call's
# value, which a pass reached through a `to_a` hop: the row answers its
# nullable Integer boxed, and the hop still unwrapped it against the nil
# sentinel #8133 retired, so the C did not build. The box is the answer
# where the call's slot is a box, and an Integer slot takes it with its nil.
def f(a) = (a.."e").find_index("c")
def g(a) = (a.."e").find_index { |s| s == "d" }
def h = "b"
p f("a"), f("d"), g("a")
x = (h.."e").find_index("c")
p x
p (h.."e").find_index("z")
y = (h.."e").find_index("d")
p y + 1 if y
z = (h.."e").find_index("q")
p z.nil?

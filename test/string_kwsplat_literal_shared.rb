# Direct calls and fresh splatted keyword values retain their behavior.
def m(k1:) = k1 << "x"
d = +"d"; m(**{ k1: d }); p d
p m(**{ k1: +"c" })
q = method(:m)
p q.call(**{ k1: +"e" }, **{})

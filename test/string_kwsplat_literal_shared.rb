# A String a call hands on through a splatted Hash literal (`**{ k: v }`) is
# the caller's String, as in CRuby, as it is through `k: v`: to a Method's
# or a proc's keyword parameter, and to a block's through a yield. It went
# over as a copy, and the append was lost.

def m(k1:) = k1 << "x"
q = method(:m)
v = +"v"; q.call(**{ k1: v }); p v
w = +"w"; q.(**{ k1: w }); p w
x = +"x"; q[**{ k1: x }]; p x
pr = proc { |k1:| k1 << "p" }
y = +"y"; pr.call(**{ k1: y }); p y
def run(v) = yield(**{ k1: v })
z = +"z"; run(z) { |k1:| k1 << "r" }; p z
d = +"d"; m(**{ k1: d }); p d
# a literal of constants keeps its own path; an empty one beside drops out
p m(**{ k1: +"c" })
e = +"e"; q.call(**{ k1: e }, **{}); p e

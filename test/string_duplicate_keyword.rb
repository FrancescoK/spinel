# A keyword a call repeats binds the later value (CRuby warns that the
# earlier is overwritten), and a String variable bound that way is the
# caller's String: a parameter that appends to it appends to the
# variable. The call built its keywords into a Hash at run time and lent
# the parameter a copy.

def kw(k:) = (p k; k)
kw(k: "a", k: "b")
def kw2(k:) = k << "x"
s = +"s"; kw2(k: s, k: s); p s
t = +"t"; kw2(k: +"z", k: t); p t
u = +"u"; kw2(k: u, k: +"z"); p u
def kw3(a, j:, k:) = (k << j; a)
v = +"v"; p kw3(1, k: "e", j: "J", k: v), v

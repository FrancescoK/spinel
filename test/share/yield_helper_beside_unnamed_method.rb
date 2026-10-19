# A method the program never names runs nothing, so the share walk leaves its
# body out (sh_dead_nodes). Here `run1` is defined and never called: its
# `q { f.call(x) }` joined q's yield value (one holder per method, not per call
# site) with what any proc may answer, so `run`'s value was no longer a new
# String and `w << "!"` was refused (#9258, cluster 9). The census is taken as
# the table stands when the walk runs, not the one an earlier phase took.
def q = yield
def run(f) = q { f.call }
def run1(f, x) = q { f.call(x) }
w = run(proc { +"new" })
w << "!"
p w
def helper(s) = s.upcase
def unused_helper(s) = (s << "?"; s)
t = +"abc"
u = helper(t)
u << "!"
p t, u

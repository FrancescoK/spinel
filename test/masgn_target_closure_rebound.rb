# spinel: gc-stress
# A target's receiver or key that reads a local is read before the right side
# runs, also where a closure the right side calls rebinds the local: a lambda, a
# proc, and a block the right side passes.
a = [0, 0, 0]
i = 0
bump = -> { i += 1; 5 }
a[i], x = bump.call, 2
p a, i
b = [0, 0, 0]
j = 0
inc = proc { j = 2; 7 }
v = (b[j], y = inc.call, 1)
p b, v
c = [0, 0, 0]
k = 0
def run = yield
c[k], z = run { k = 2; 9 }, 3
p c

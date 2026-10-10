# `n.step` with no arguments on a receiver only known at run time to be an
# Integer or a Float walks from n by 1 without end, as on a typed receiver:
# the boxed dispatch had no arm for it and raised NoMethodError.
def pick(i) = i == 0 ? 3 : 1.5

n = pick(0)
p n.step.first(3)
p n.step.size
p n.step.lazy.map { |x| x * 2 }.first(2)
p n.step.take(2)
e = n.step
p e.next, e.next

f = pick(1)
p f.step.first(3)

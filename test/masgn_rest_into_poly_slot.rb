# A rest target in a multiple assignment into a local or global that
# already holds another type boxes the collected array.

b = 0
a, *b = 1, 2, 3
p a, b
p b.sum
b << 4
p b

c = 0
*c, d = 1, 2, 3
p c, d

e = 0
a, *e, f = 1, 2, 3, 4
p a, e, f

g = ["s"]
a, *g = 1, 2, 3
p g

h = 0
a, *h = 1, "s", nil, 2.5
p h

i = :x
a, *i = 1
p i

$g = 0
a, *$g = 1, 2, 3
p a, $g

$h = [1, "x"]
a, *$h = 1, 2, 3
p $h

x = 1
x = [1, 2, 3]
j = 0
a, *j = x
p a, j

k = nil
k = 5
*k, l = x
p k, l

pair3 = [1, 2, 3]
m = 0
a, *m = pair3
p m

def rest_in_method
  r = "x"
  a, *r = 1, 2.5, 3.5
  p a, r.sum
  r = nil
  p r
end
rest_in_method

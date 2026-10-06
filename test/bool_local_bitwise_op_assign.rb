# |=, &= and ^= on a true/false local answer the operator's boolean from
# the operand's truthiness, the operand evaluated in every case (#7271).
a = true
b = false
a &= b
p a
c = false
c |= true
p c
d = true
d ^= true
p d
def f(x) = (x |= false; x)
p f(true)
e = true
e &= nil
p e
g = false
g |= "s"
p g
h = true
calls = 0
h &= (calls += 1; false)
p [h, calls]
k = false
[1, 2].each { |i| k |= i > 1 }
p k

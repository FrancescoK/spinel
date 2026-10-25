# An element of an Array subclass instance, read as an operand
class A < Array
end
a = A.new([4, 5, 6])
p a[0] + 1
p a[0] * 2, a[1] - 1, a[2] / 2, a[0] % 3, a[0] < 5, a[0] == 4, a[1] <=> 5
p a[0].to_s, a[-1].succ, -a[0]
p [a[0] + 1, a[1] + 2]
h = {k: a[0] + 1}
p h
def f(x) = x + 1
p f(a[0] + 1)
p 5 - a[1]
class F < Array
end
f = F.new([1.5, 2.5])
p f[0] + 1.0
p f[1] * 2

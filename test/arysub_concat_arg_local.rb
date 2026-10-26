# Array#concat as a value takes an Array subclass instance held in a local as its Array.

class A < Array; end
class F < Array; end
a = A.new([1, 2])
f = F.new([1.5])
s = A.new(["y"])
p [9].concat(a, [3])
b = [9]
b.concat(a)
p b
x = [0.5]
x.concat(f)
p x
p [0.5].concat(f)
def add(t, u) = t.concat(u)
p add([7], a)
@iv = A.new([4])
p [1].concat(@iv)
p [9] + a
p [9, 1, 2] - a
p [1, 2] == a
p [1, 5] & a
p [1, 5] | a
c = [0]
c.replace(a)
p c
p [1].zip(a)
p [3].product(a)
p ["x"].concat(s, ["z"])
n = A.new([nil, 1])
p [5].concat(n)
p a.class
p [9].concat(a).class
p [9].push(*a)
y = [8]
r = y.concat(a)
r << 99
p y
p a

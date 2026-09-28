# curry(n) on a Proc read out of a container answers a curry that calls
# once n arguments have arrived, as on a typed Proc.
add = proc { |a, b, c| a + b + c }
x = [add, 0][0]
c = x.curry(3)
p c[1][2][3]
s = [proc { |*xs| xs.sum }, 0][0]
p s.curry(2)[10][20]
p s.curry(4)[1][2][3][4]
p x.curry(nil)[1][2][3]
p x.curry([3, "s"][0])[4][5][6]
l = [lambda { |a, b| a * b }, 0][0]
p l.curry(2)[6][7]
p (l.curry(3) rescue $!.message)
o = [->(a, b = 5) { a + b }, 0][0]
p o.curry(2)[1][2]
p (o.curry(3) rescue $!.message)
kl = [lambda { |a, k: 1| [a, k] }, 0][0]
p kl.curry(2).lambda?
p (kl.curry(3) rescue $!.message)
p ([nil, 0][0].curry(2) rescue $!.message)

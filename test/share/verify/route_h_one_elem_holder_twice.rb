def mk = +"a"
a = []
x = mk
a.push(x, x)
x = nil
a.last << "!"
p a

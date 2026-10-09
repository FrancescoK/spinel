s = +"abc"
t = s
e = RuntimeError.new(s); e.message << "!"
p s
p t

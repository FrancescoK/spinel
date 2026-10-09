f = ->(a) { a } >> ->(b) { b }
s = +"abc"
t = f.call(s)
t << "!"
p s

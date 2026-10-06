# s.method(:<<) is a Method on s itself; calling it appends to s. It
# crashed: refused rather than compiled.
s = +"abc"
s.method(:<<).call("!")
p s

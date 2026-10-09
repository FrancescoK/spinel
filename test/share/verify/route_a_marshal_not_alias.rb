s = +"abc"
r = Marshal.load(Marshal.dump(s))
r << "!"
p s
p r

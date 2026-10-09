s = +"abc"
t = s
Marshal.load(Marshal.dump(s)) << "!"
p s
p t

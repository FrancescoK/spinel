s = +"abc"
t = s
r, w = IO.pipe; w.write("Z"); w.close; r.read(1, s)
p s
p t

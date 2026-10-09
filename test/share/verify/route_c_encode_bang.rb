s = +"abc"
t = s
s.encode!("UTF-8", "UTF-8")
p s
p t

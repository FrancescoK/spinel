s = +"abc"
t = s
s.instance_eval { upcase! }
p s
p t

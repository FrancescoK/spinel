s = +"abc"
t = s
s.instance_exec("!") { |x| concat(x) }
p s
p t

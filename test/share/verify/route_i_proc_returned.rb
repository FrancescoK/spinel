def mk = proc { |x| $kept = x }
pr = mk
s = +"abc"
pr.call(s)
s << "!"
p $kept

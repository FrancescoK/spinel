s = +"abc"
t = s
class K; def mut(x) = x << "!"; end; nm = "mut"; K.new.send(nm.to_sym, s)
p s
p t

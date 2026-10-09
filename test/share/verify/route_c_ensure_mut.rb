s = +"abc"
t = s
begin; nil; ensure; s << "!"; end
p s
p t

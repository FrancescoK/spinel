s = +"abc"
t = s
begin; raise ArgumentError, s; rescue => e; e.message << "!"; end
p s
p t

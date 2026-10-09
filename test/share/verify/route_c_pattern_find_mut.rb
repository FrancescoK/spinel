s = +"abc"
t = s
case [1, s]
in [*, String => x, *] then x << "!"
end
p s
p t

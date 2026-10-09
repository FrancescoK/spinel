s = +"abc"
r = nil
case {name: s}
in {name: t}
  r = t
end
r << "!"
p s
p r

s = +"abc"
r = nil
case s
in String => t
  r = t
end
r << "!"
p s
p r

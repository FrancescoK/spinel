s = +"abc"
i = 0
r = until i > 0
  i += 1
end
p r
t = s
t << "!" if r.nil?
p s

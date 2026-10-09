s = +"abc"
r = [s].to_h { |x| [1, x] }[1]
r << "!"
p s
p r

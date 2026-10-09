s = +"abc"
r = [s].lazy.map { |x| x }.first
r << "!"
p s
p r

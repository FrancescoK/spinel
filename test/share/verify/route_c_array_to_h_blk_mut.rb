s = +"abc"
t = s
[s].to_h { |x| [x << "!", 1] }
p s
p t

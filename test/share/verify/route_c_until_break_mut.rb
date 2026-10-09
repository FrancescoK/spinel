s = +"abc"
t = s
(until false do break s end) << "!"
p s
p t

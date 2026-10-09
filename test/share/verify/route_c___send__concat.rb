s = +"abc"
t = s
s.__send__(:concat, "!")
p s
p t

s = +"abc"
t = s
Thread.new { s }.value << "!"
p s
p t

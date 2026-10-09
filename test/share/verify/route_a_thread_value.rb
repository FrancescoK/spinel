s = +"abc"
r = Thread.new { s }.value
r << "!"
p s
p r

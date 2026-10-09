s = +"abc"
t = s
Thread.new { s << "!" }.join
p s
p t

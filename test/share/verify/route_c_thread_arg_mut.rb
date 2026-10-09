s = +"abc"
t = s
Thread.new(s) { |x| x << "!" }.join
p s
p t

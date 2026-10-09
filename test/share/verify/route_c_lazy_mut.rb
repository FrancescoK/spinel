s = +"abc"
t = s
[s].lazy.each { |x| x << "!" }.to_a
p s
p t

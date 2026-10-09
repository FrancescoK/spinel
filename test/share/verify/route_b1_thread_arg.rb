$h = nil
s = +"abc"
Thread.new(s) { |v| $h = v }.join
s << "!"
p($h)
p s

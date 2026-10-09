$h = nil
s = +"abc"
Thread.new(s) { |v| $h = v }.join
($h) << "?"
p s
p($h)

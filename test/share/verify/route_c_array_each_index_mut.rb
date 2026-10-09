s = +"abc"
t = s
a = [s]; a.each_index { |i| a[i] << "!" }
p s
p t

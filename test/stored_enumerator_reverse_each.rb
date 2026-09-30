rr = (1..3).reverse_each
p rr.each { |x| print x, " " }
hr = {a: 1, b: 2}.reverse_each
p hr.each { |k, v| print k, v, " " }
ar = [4, 5, 6].reverse_each
p ar.each { |x| print x, " " }
re = (1..3).each_entry
p re.each { |x| print x, " " }
he = {a: 1, b: 2}.each_entry
p he.each { |pair| print pair.inspect, " " }

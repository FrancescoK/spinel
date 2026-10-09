s = +"s"
t = s
procs = (1..5).map { |i| ->(x) { x << i.to_s; junk = "q" * 100; x } }
40.times { procs.each { |pr| pr.call(t) } }
p s.size, s[0, 20]

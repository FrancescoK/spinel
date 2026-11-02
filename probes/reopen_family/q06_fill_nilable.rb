def f(pr) = Array.new(3, 0).fill(7, &pr)
p f(nil)
p f(->(i) { i * 10 })
pr = nil
p [1, 2].fill(5, &pr)
pr = proc { |i| i + 100 }
p [1, 2].fill(5, &pr)

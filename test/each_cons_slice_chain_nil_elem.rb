# each_cons(n) and each_slice(n) chained into an iterator whose block takes
# a row's elements bind a nil element (or the nil past a short last row) as
# nil, over an Integer or a Float Array.
a = [1, 2]
a[3] = 5
p a.each_cons(2).map { |x, y| [x, y] }
p a.each_slice(2).map { |x, y| [x, y] }
p a.each_slice(3).map { |x, y, z| [x, y, z] }
p a.each_cons(2).map { |(x, y)| x.nil? ? -1 : x }
p a.each_slice(2).map { |(x, y)| [x, y] }
p a.each_cons(2).filter_map { |x, y| x if y }
p a.each_cons(2).count { |x, y| x.nil? }

f = [1.5, 2.5]
f[3] = 0.5
p f.each_cons(2).map { |x, y| [x, y] }
p f.each_slice(2).map { |x, y| [x, y] }

b = [1, 2, 3]
p b.each_cons(2).map { |x, y| x + y }
p b.each_slice(2).map { |x, y| [x, y] }

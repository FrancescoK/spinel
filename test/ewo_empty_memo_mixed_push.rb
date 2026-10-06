# An empty array memo filled with values whose type settles late took the
# first kind it saw (a String from `n.to_s` beside a still-open `n`), and
# the Integer push then raised "cannot store Integer into an Array[String]".
p [1, 2, 3].each_with_object([]) { |n, a| a << (n.even? ? n.to_s : n) }
p [1, 2, 3].each_with_object([]) { |n, a| a.push(n.even? ? n.to_s : n) }
p [1, 2, 3].each_with_object([]) { |n, a| v = n.odd? ? n : n.to_s; a << v }
p [1, 2, 3].each_with_object([]) { |n, a| a << n * 2 }
p %w[a b].each_with_object([]) { |s, a| a << s.upcase }
def gather(xs, memo)
  xs.each { |x| yield x, memo }
  memo
end
p gather([1, 2], []) { |x, m| m << (x > 1 ? x.to_s : x) }

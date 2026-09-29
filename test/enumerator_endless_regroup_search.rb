e = Enumerator.new { |y| i = 0; loop { y << (i += 1) } }
p e.each_slice(2).find { |a| a.sum > 10 }
p e.each_slice(2).detect { |a| a.sum > 10 }
p e.each_slice(2).include?([3, 4])
p e.each_slice(2).member?([5, 6])
p e.each_cons(3).find { |a| a.sum > 20 }
p e.each_cons(2).include?([4, 5])
p e.each_slice(2).find_index { |a| a[0] > 6 }
p e.each_slice(2).find_index([3, 4])
p e.each_slice(2).take_while { |a| a[0] < 6 }
p e.each_slice(2).any? { |a| a.sum > 10 }
p e.each_slice(2).first(2)
p e.each_slice(2).each_with_index.find { |a, i| i == 2 }
p e.each_with_index.find { |x, i| x * i > 10 }
p e.each_with_index.include?([3, 2])

a = [1, 2, 3, 4, 5]
p a.each_slice(2).find { |s| s.sum > 4 }
p a.each_slice(2).find { |s| s.sum > 40 }
p a.each_slice(2).include?([3, 4])
p a.each_slice(2).include?([4, 5])
p a.each_cons(2).find { |s| s[1] == 4 }
p a.each_cons(2).find_index([2, 3])
p a.each_slice(2).take_while { |s| s[0] < 3 }
p a.each_with_index.find { |x, i| x * i > 5 }
p a.each_with_index.include?([3, 2])
p a.each_with_index.find_index([3, 2])
p (1..6).each_slice(2).find { |s| s.sum > 5 }
p (1..6).each_slice(2).include?([3, 4])
p (1..).each_slice(2).find { |s| s.sum > 5 }
h = {a: 1, b: 2, c: 3}
p h.each_slice(2).find { |s| s.size == 1 }
p h.each_slice(2).include?([[:c, 3]])
p e.each_slice(2).all? { |a| a.sum < 10 }
p e.each_slice(2).none? { |a| a.sum > 10 }
p e.each_cons(2).any? { |a| a.sum > 10 }
p e.each_with_index.any? { |x, i| x + i > 10 }
p e.each_slice(2).lazy.map { |a| a.sum }.first(3)
p e.each_slice(2).each_with_index.first(2)
p((1..).each_cons(2).include?([4, 5]))
begin
  (1..4).each_slice(0)
rescue ArgumentError => x
  p x.message
end

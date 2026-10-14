t = [nil, 9][0]
p 1.step(by: 2, to: t).first(3)
p 1.step(t, 2).first(3)
p 1.step(t).first(4)
p 1.step(t, 3).each_slice(2).first(2)
1.step(t, 2).each { |i| print i; break if i > 2 }
puts
begin
  1.step(t, 0)
rescue ArgumentError => e
  p e.message
end
u = [nil, 9][1]
p 1.step(by: 2, to: u).first(3)
p 1.step(u, 2).to_a
p 1.step(u, 2).map { _1 * 10 }
p 1.step(u, 2).sum

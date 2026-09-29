t = true
f = false
n = nil
bx = [false, 1, nil, true]
p(t <=> bx[0])
p(f <=> bx[0])
p(n <=> bx[2])
p(n <=> bx[1])
p(t <=> bx[3])
a = [1, "a", :b]
p a.min_by { |x| false }
p a.max_by { |x| nil }
p a.min_by { |*| true }
p [3, 1].min_by { |x| x > 5 }
begin
  p [1, 2].min_by { |x| x == 1 }
rescue ArgumentError => e
  p e.message
end

# A for loop's value is its collection, or the value of a `break` (nil
# for a bare one).
r = for x in [1]; end
p r

def coll
  puts "coll"
  [3, 4]
end
p(for y in coll; puts y; end)

p(for i in 1..3; end)
lo = 2
p(for j in lo...5; end)

h = {a: 1}
p(for k, v in h; p [k, v]; end)
p(for a, b in [[1, 2], [3, 4]]; end)

p(for s in %w[a b]; break s.upcase if s == "b"; end)
p(for t in %w[a b]; break if t == "a"; end)
p(for u in [1, 2]; break u * 100 if u == 2; end)

def m = for q in [5, 6]; q; end
p m

def sm(xs) = for w in xs; end
p sm(["a"])
p sm([1.5])

z = [for e in [7]; end, 1]
p z
c = true
p(c ? (for f in [9]; end) : 2)
puts "#{for g in [1, 2]; end}"
p [1, 2].map { |n| for o in [n]; end }

total = 0
res = for n2 in [1, 2, 3]
  next if n2 == 1
  total += n2
end
p res, total

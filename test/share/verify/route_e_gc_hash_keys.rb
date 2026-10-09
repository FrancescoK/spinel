h = {}
k = +"key"
k2 = k
100.times do |i|
  h[k] = (h[k] || 0) + 1
  k2 << i.to_s if i % 10 == 0
  junk = Array.new(20) { |j| "#{j}" * 2 }
  h.key?(k)
  h.fetch(k, 0)
end
p h.size, h.values.sum, k
p h.keys.all?(&:frozen?)

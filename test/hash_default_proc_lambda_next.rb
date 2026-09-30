h = Hash.new
h.default_proc = ->(hh, k) { next 7 if k == :x; 0 }
p h[:x]
p h[:y]

g = Hash.new
g.default_proc = ->(hh, k) { next if k == 1; k * 2 }
p g[1]
p g[2]

s = Hash.new
s.default_proc = ->(hh, k) do
  if k.size < 3
    next "short"
  end
  k.upcase
end
p s["ab"]
p s["abcd"]

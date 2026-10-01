# A lambda or proc whose tail has no value answers what a `next <v>` hands
# back, including a lambda installed as a Hash's default_proc.
h = Hash.new
h.default_proc = ->(hh, k) { next k.to_s * 2 if k.is_a?(Symbol); nil }
p h[:ab]
p h[1]

l = ->(k) { next "s" if k; nil }
p l.(true)
p l.(false)

pr = proc { |k| next [k] if k }
p pr.(1)
p pr.(nil)

lv = ->(k) { next 5 if k; puts "tail" }
p lv.(true)
p lv.(false)

g = {}
g.default_proc = ->(hh, k) { if k.size > 2 then next hh[k] = k.upcase end; nil }
p g["abc"]
p g["ab"]
p g

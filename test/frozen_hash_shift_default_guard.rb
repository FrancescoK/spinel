# shift, default=, default_proc= and a default block's own store refuse a frozen Hash of every layout.
def try
  yield
  :noraise
rescue FrozenError
  :frozen
end

si = {a: 1}.freeze
ss = {"a" => "b"}.freeze
ii = {1 => 2}.freeze
sp = {a: "x", b: 2}.freeze
tp = {"a" => 1, "b" => "x"}.freeze
pq = {1 => "a", :b => 2}.freeze
dd = Hash.new(0).freeze
e = {}.freeze

p try { si.shift }, try { ss.shift }, try { ii.shift }
p try { sp.shift }, try { tp.shift }, try { pq.shift }
p try { dd.shift }, try { e.shift }
p try { si.default = 5 }, try { ss.default = "z" }, try { ii.default = 9 }
p try { sp.default = 1 }, try { tp.default = 1 }, try { pq.default = 1 }
p try { dd.default = 1 }
p try { sp.default_proc = ->(h, k) { k } }
p try { tp.default_proc = ->(h, k) { k } }
p try { pq.default_proc = ->(h, k) { k } }
pr = proc { |h, k| k }
p try { sp.default_proc = pr }
p si, ss, ii, sp, tp, pq, dd, e
p dd[:q], sp[:q]

h = Hash.new { |hh, k| hh[k] = k * 2 }.freeze
p try { h[3] }, h.size
g = Hash.new { |hh, k| hh[k] = [] }.freeze
p try { g[:a] << 1 }, g
st = Hash.new { |hh, k| hh.store(k, 7) }.freeze
p try { st[3] }, st.size
ro = Hash.new { |hh, k| k * 10 }.freeze
p ro[4], ro.size

begin
  ii.shift
rescue FrozenError => ex
  p ex.receiver.equal?(ii)
end

def first_pair(hh) = hh.shift
p try { first_pair({"k" => 1}.freeze) }
p first_pair({"k" => 1})

u = {a: 1, b: 2}
p u.shift, u
u.default = 7
p u[:zz]
m = Hash.new { |hh, k| hh[k] = [] }
m[:a] << 1; m[:b] << 2; m[:a] << 3
p m
lp = {a: 1}
lp.default_proc = ->(hh, k) { k.to_s }
p lp[:b]

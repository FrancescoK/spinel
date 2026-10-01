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

# default= evaluates its argument once, and before the frozen check.
class Pt; def initialize(x) = @x = x; attr_reader :x; end
def ev_i(x) = (puts "eval #{x}"; x)
def ev_s(x) = (puts "eval #{x}"; x)
def ev_y(x) = (puts "eval #{x}"; x)
def ev_f(x) = (puts "eval #{x}"; x)
def ev_o(x) = (puts "eval #{x.x}"; x)
def ev_n = (puts "eval nil"; nil)
di = {"a" => 1}
p(di.default = ev_i(5), di["z"])
ds = {"a" => "s"}
p(ds.default = ev_s("d"), ds["z"])
dp = {a: 1, "b" => :c}
p(dp.default = ev_y(:q), dp[:z])
p(dp.default = ev_f(2.5), dp[:z])
p((dp.default = ev_o(Pt.new(7))).x, dp[:z].class)
p(dp.default = ev_n, dp[:z])
p(dp.default = nil, dp[:z])
ii = {1 => 2}
p(ii.default = nil, ii[9])
[di, ds, dp].each(&:freeze)
begin; di.default = ev_i(9); rescue => e; p e.class; end
begin; ds.default = ev_s("e"); rescue => e; p e.class; end
begin; dp.default = ev_y(:r); rescue => e; p e.class; end
p di["z"], ds["z"], dp[:z]

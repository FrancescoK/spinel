# A Hash's default answers every read of a missing key. values_at on a
# typed-value Hash (String or Integer keys, Integer or String values) with a
# default answered nil for a missing key, and for a key of another class,
# where h[key] answers the default. A default value and a default block
# replace each other: `h.default = v` kept the block, which went on
# answering misses and default_proc, and `h.default_proc = pr` kept the
# value, which default went on answering. `h.default_proc = nil` removes
# both; it raised NoMethodError. Installing a default proc on a typed-value
# local widened it every round, so type inference did not converge. A boxed
# Hash refused `default_proc = pr` with a TypeError and answered itself.

si = Hash.new(0); si["a"] = 1
p si.values_at("a", "b"); p si.values_at(:x, 1, "a"); p si.values_at(*["a", "q"])
p si.dig("b"); p si.default("b"); p si.to_proc.call("q"); p ["z", "a"].map(&si)
p(begin; si.fetch_values("b"); rescue KeyError => e; e.message; end)
ss = Hash.new("d"); ss["a"] = "x"
p ss.values_at("a", "b"); p ss.values_at(:a, nil)
is = Hash.new("d"); is[1] = "x"
p is.values_at(1, 2)
ii = Hash.new(5); ii[1] = 2
p ii.values_at(1, 2); p ii.values_at("1", 1.0, 1); p ii.values_at(*[3, 1])
sy = Hash.new(:dd); sy[:a] = 1; sy[:b] = "s"
p sy.values_at(:a, :c, "a")
sp = Hash.new(3); sp["a"] = 1; sp["b"] = [2]
p sp.values_at("a", "c", :c)
pp1 = Hash.new(4); pp1[1] = "x"; pp1["y"] = 2; pp1[:z] = 3
p pp1.values_at(1, :q)
g = {"a" => 1}; g.default = 5
p g.values_at("a", "z", :z)
g2 = {"a" => "s"}; g2.default = "t"
p g2.values_at("z")
g3 = {1 => 1}; g3.default = 6
p g3.values_at(9)
bs = Hash.new { |hh, kk| "blk" }; bs["a"] = [1]
p bs.values_at(:zz, 3, "a")
by = Hash.new { |hh, kk| 9 }; by[:a] = "s"
p by.values_at("a", :q)
y = [si, 1][0]
p y.values_at("a", "b", :c)

# default= replaces a default block
k = Hash.new { |hh, kk| 7 }; k["a"] = 1; k.default = 3
p k["q"]; p k.default_proc; p k.default; p k.values_at("q"); p k.fetch("q", 0)
k2 = Hash.new { |hh, kk| 7 }; k2[:a] = 1; k2.default = 3
p k2[:q]; p k2.default_proc
k3 = Hash.new { |hh, kk| "x" }; k3["a"] = "s"; k3.default = "y"
p k3["q"]; p k3.default_proc
k4 = Hash.new { |hh, kk| 7 }; k4[1] = 2; k4.default = 3
p k4[5]; p k4.default_proc
k5 = Hash.new { |hh, kk| 7 }; k5["a"] = 1; k5.default = nil
p k5["q"]; p k5.default_proc
k6 = Hash.new { |hh, kk| 7 }; k6["a"] = 1
b6 = [k6, 1][0]; b6.default = 3
p k6["q"]; p k6.default_proc

# default_proc= replaces a default value
m = Hash.new(4); m[:a] = 1; m.default_proc = proc { |hh, kk| 8 }
p m[:q]; p m.default
m1 = Hash.new(4); m1["a"] = 1; m1.default_proc = proc { |hh, kk| 8 }
p m1["q"]; p m1.default; p m1.default_proc.nil?
m3 = Hash.new(4); m3[1] = 1; m3.default_proc = proc { |hh, kk| 8 }
p m3[5]; p m3.default
m2 = {"a" => 1}; m2.default_proc = proc { |hh, kk| 9 }; m2.default = 2
p m2["z"]; p m2.default_proc

# ...through a boxed Hash too, which raised TypeError, and the assignment
# answers the Proc
bm = Hash.new(4); bm[:a] = "s"
bz = [bm, 1][0]
br = (bz.default_proc = proc { |hh, kk| hh[kk] = kk.to_s * 2 })
p br.class; p bm[:q]; p bm; p bm.default
bs = Hash.new(4); bs["a"] = [1]
bw = [bs, 1][0]
bw.default_proc = proc { |hh, kk| kk.size }
p bs["xyz"]; p bs.default; p bs.default_proc.nil?
bw.default = 9
p bs["q"]; p bs.default_proc
bp = Hash.new(4); bp[1] = "x"; bp[:b] = 2
bv = [bp, 1][0]
bv.default_proc = proc { |hh, kk| [kk] }
p bp[:zz]; p bp.default
bpr = proc { |hh, kk| kk }
bx = Hash.new(4); bx[:a] = "s"
[bx, 1][0].default_proc = bpr
p bx.default_proc.equal?(bpr)
b7 = Hash.new { |hh, kk| 7 }; b7[:a] = [1]
bb7 = [b7, 1][0]; bb7.default_proc = nil
p b7[:q]; p b7.default_proc

# default_proc = nil removes both
n = Hash.new(4); n["a"] = 1; n.default_proc = nil
p n["q"]; p n.default
n2 = Hash.new { |hh, kk| 7 }; n2[:a] = 1
p(n2.default_proc = nil)
p n2[:q]; p n2.default; p n2.default_proc
class IvarHashes
  def initialize
    @si = Hash.new(4); @si["a"] = 1
    @is = Hash.new("x"); @is[1] = "y"
  end

  def clear
    @si.default_proc = nil
    @is.default_proc = nil
  end

  def show = p([@si["q"], @si.default, @is[2], @is.default])
end
ih = IvarHashes.new
ih.show
ih.clear
ih.show

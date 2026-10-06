# spinel: int64
# Hash#to_proc called with a key of a class the Hash's storage cannot hold
# (an Integer or a Symbol on a String-keyed Hash, a Float 1.0 on an
# Integer-keyed one, which is not eql? to 1) is a miss: it answers nil or the
# Hash's default, as h[key] does. The lookup read the proc's raw argument
# slot as the storage's key type, so a String-keyed Hash called with an
# Integer dereferenced the Integer as a string pointer and crashed.

si = {"a" => 1}.to_proc
p si.call("a"); p si.call("z"); p si.call(1); p si.call(:a); p si.call(nil); p si.call(1.0)
p si.call(+"a")
ss = {"a" => "x"}.to_proc
p ss.call("a"); p ss.call(2); p ss.call(:a)
ii = {1 => 2}.to_proc
p ii.call(1); p ii.call(1.0); p ii.call("1"); p ii.call(:a); p ii.call(2**70)
is = {1 => "one"}.to_proc
p is.call(1); p is.call(1.0); p is.call("1")
sy = {a: 1, b: "s"}.to_proc
p sy.call(:a); p sy.call("a"); p sy.call(0); p sy.call(nil)
sp = {"a" => 1, "b" => "s"}.to_proc
p sp.call("b"); p sp.call(:b); p sp.call(3)
pp1 = {1 => "x", "y" => 2, :z => 3}.to_proc
p pp1.call(1); p pp1.call(1.0); p pp1.call(:z); p pp1.call("q")

# an emptied local Hash typed String-keyed
h = {}
h["x"] = [1, "s"]
h.delete("x")
p h.to_proc.call(1)

# a miss answers the default value or the default block
d1 = Hash.new(9); d1["k"] = 3
p d1.to_proc.call(:zz); p d1.to_proc.call(5); p d1.to_proc.call("k"); p d1.to_proc.call("m")
d2 = Hash.new("dflt"); d2["k"] = "v"
p d2.to_proc.call(1); p d2.to_proc.call("k")
d3 = Hash.new(7); d3[1] = 2
p d3.to_proc.call(1.0); p d3.to_proc.call("1"); p d3.to_proc.call(4)
d4 = Hash.new { |hh, k| "blk" }; d4["a"] = [1]
p d4.to_proc.call(1); p d4.to_proc.call("a"); p d4.to_proc.call("b")
d5 = Hash.new { |hh, k| 42 }; d5[:a] = "s"
p d5.to_proc.call("a"); p d5.to_proc.call(:a); p d5.to_proc.call(:q)

# other ways to reach the proc
pr = {"a" => 1}.to_proc
p pr.(1); p pr[2]; p pr.yield(:s)
p (pr >> ->(x) { x.inspect }).call(3)
p [1, "a"].map(&{"a" => 1})
def run(f, k) = f.call(k)
p run(pr, 7); p run(pr, "a")
x = [1, "a", :a, nil, 2.0][1]
p pr.call(x)
p [1.0, 1].map(&{1 => 2})
p [0, :a].map(&{a: 1})
f = [1.0, "s"][0]
p ii.call(f)

# The Proc Hash#default_proc answers for a Hash.new { |hash, key| ... } block
# can be called with any Hash, or anything else, as CRuby's can. It read its
# first argument as a Hash of the receiver's own kind, so a Hash of another
# kind crashed, and nil or an Integer stood for the receiver itself. A Hash
# of another kind now goes in as a general copy written back after the block
# ran; a block that ignores its Hash answers for any first argument; the
# arguments are taken as a proc takes them (nil for a missing one, one Array
# spread over both).

def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message[0, 40]}"
end

m = Hash.new { |hh, kk| hh[kk] = 1 }
m[1] = "s"
dp = m.default_proc
t { dp.call({}, "w") }
x = {}
x[:z] = 0
t { dp.call(x, :v) }
p x
y = {"a" => 1}
t { dp.call(y, "b") }
p y
q = {1 => 2}
t { dp.call(q, 5) }
p q
pp2 = {1 => "x", :b => [2]}
t { dp.call(pp2, "k") }
p pp2
fz = {"a" => 1}.freeze
t { dp.call(fz, "b") }
p fz
t { dp.(m, 9) }
p m
t { dp[{"s" => 1}, "t"] }
t { dp.yield({"s" => 1}, "u") }

# a block that ignores its Hash
r = Hash.new { |hh, kk| kk.to_s * 2 }
r[:a] = [1]
rp = r.default_proc
t { rp.call(5, 7) }
t { rp.call(nil, :q) }
t { rp.call(:x) }
t { rp.call }
t { rp.call([{}, :ab]) }
t { rp.call({}, :c, :extra) }
p rp.lambda?
p [[{}, :s], [{}, "t"]].map(&rp)
t { (rp >> ->(v) { v.size }).call({}, :abc) }

# the Proc as another Hash's default
n = Hash.new(&rp)
n["k"] = 1
p n[:zz]
w = {"a" => [1]}
w.default_proc = rp
p w["bb"]
memo = {"a" => [1]}
memo.default_proc = dp
p memo["c"]; p memo

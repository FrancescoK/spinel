# A fetch block's parameter on a receiver that may be a Hash or an Array,
# in a program that also reads the receiver with a Symbol key. The read
# types the still untyped local as a Hash of Symbol keys for one round of
# inference; the block's parameter took that key type and kept it when the
# local was boxed, so `k * 2` multiplied a "Symbol" and the Hash arm was
# left out: "undefined method 'fetch' for an instance of Hash".

def pick(n) = n > 0 ? {"a" => 1, :s => 2, 3 => 4} : [10, 20]

x = pick(1)
p x[:s]
p(x.fetch(9) { |k| k * 2 })
p(x.fetch(2.5) { |k| k + 1 })
p(x.fetch(3) { |k| k * 2 })          # present: the block is not called
p(x.fetch(9) { |k| [k, k.to_s] })
p(x.fetch(nil) { |k| k.inspect })
p(x.fetch(true) { |k| k ? "yes" : "no" })
p(x.fetch([1, 2]) { |k| k.size })
p(x.fetch(1..3) { |k| k.sum })
@i = 9
p(x.fetch(@i) { |k| k + 1 })

# beside a Symbol fetch whose block names no parameter
y = pick(1)
p(y.fetch(:zz) { :none })
p(y.fetch(7) { |i| i + 1 })
p(y.fetch(1.5) { |f| [f, f * 2] })

# the read after the fetch
z = pick(1)
p(z.fetch(8) { |k| k - 1 })
p z[:s]

# an Array at run time: the block gets the index
a = pick(0)
p a[:s] if a.is_a?(Hash)
p(a.fetch(5) { |i| i * 3 })
p(a.fetch(1) { |i| i * 3 })

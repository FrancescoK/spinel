# A Proc given to Hash.new as its block argument, or assigned through
# default_proc=, is the hash's default: missing keys run it, and
# default_proc answers that same Proc (== and equal?).

pr = proc { |h, k| "d:#{k}" }
h = Hash.new(&pr)
p h[3]
p h.default_proc == pr
p h.default_proc.equal?(pr)
p h.size

lam = lambda { |hh, k| hh[k] = k.to_s * 2 }
g = Hash.new(&lam)
p g[:ab]
p g
p g.default_proc.equal?(lam)
p g.default_proc.lambda?

none = nil
n = Hash.new(&none)
p n[1]
p n.default_proc

s = {"a" => 1, "b" => [2]}
s.default_proc = pr
p s["zz"]
p s.default_proc == pr

y = {a: 1, b: "x"}
y.default_proc = pr
p y[:q]
p y.default_proc.equal?(pr)

z = {1 => :one, "two" => 2}
z.default_proc = pr
p z[9]
p z.default_proc == pr

blk = Hash.new { |hh, k| k * 3 }
p blk[4]
p blk.default_proc.call({}, 5)
p({}.default_proc)

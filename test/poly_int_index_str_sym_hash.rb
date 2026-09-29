# An Integer index on a String- or Symbol-keyed Hash read out of a mixed
# value is a miss. It was looked up as a Symbol id (on a String-keyed Hash,
# as that Symbol's name), so `h[0]` answered whatever sat under Symbol 0.
s = :abc
t = :zz

def pick(f) = f ? {"abc" => 10, "zz" => "x"} : [1, 2, 3]
def picks(f) = f ? {abc: 10, zz: "x"} : [1, 2, 3]
h = pick(true)
g = picks(true)
p h[0], h[1], h[-1], h[5]
p g[0], g[1], g[-1], g[5]
n = 0
p h[n], g[n], h[n + 1], g[n + 1]
p [h][0][1], [g][0][0]

# the keys the Hashes do hold, and the Array the same methods can return
p h["abc"], g[:abc], h[s.to_s], g[t]
a = pick(false)
p a[0], a[-1]
p pick(true).fetch(0, "none"), picks(true).fetch(0, "none")

# the miss answers the default, or calls the default block
sp = Hash.new(7)
sp["abc"] = "v"
sp["zz"] = 1
yp = Hash.new(7)
yp[:abc] = 1
yp[:zz] = "x"
dp = {"abc" => 1, "zz" => "x"}
dp.default_proc = proc { |hh, k| "dp" }
[sp, yp, dp].each do |d|
  e = [d, 1][0]
  p [e[0], e[1], e[3]]
end

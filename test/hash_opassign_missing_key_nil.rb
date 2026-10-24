# h[k] op= v on a missing key reads h[k] first. A Hash with no default
# answers nil, and nil + 1 is NoMethodError, as a plain h[k] + 1 is.
# A Hash with a default (value or block) folds onto the default.

class Counter
  def initialize(c = {1 => 0})
    @c = c
  end

  def bump(k)
    @c[k] += 1
  end
end

def try
  yield
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end

o = Counter.new
p o.bump(1)
try { p o.bump(2) }

h = {1 => 0}
try { h[2] += 1 }
try { h[2] -= 1 }
try { h[2] *= 3 }
p h

sh = {"a" => 5}
try { sh["b"] += 1 }
sh["a"] -= 2
p sh

st = {1 => "a"}
try { st[2] += "x" }
st[1] += "b"
p st

z = Hash.new(0)
z[2] += 1
z[2] += 1
p z

d = Hash.new(10)
d[1] -= 3
d[2] *= 2
p d

b = Hash.new { |hh, k| hh[k] = 0 }
b[5] += 4
p b

s = Hash.new("")
s[1] += "x"
s[1] += "y"
p s

e = {"k" => 1}
e.default = 7
e["n"] += 1
p e

words = %w[x y x z x]
cnt = Hash.new(0)
words.each { |w| cnt[w] += 1 }
p cnt

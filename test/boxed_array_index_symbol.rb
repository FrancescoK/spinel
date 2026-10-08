# A Symbol or a String is no index of an Array. Through a boxed receiver the
# store already raised the TypeError (sp_poly_set_sym, sp_poly_set_str); the
# read answered nil.

def pick(n) = n > 0 ? {a: 1} : [[1, "s"], [2, "t"]]

def report
  yield
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

h = pick(0)
report { p h[:a] }
report { p h["a"] }
report { p h.fetch(:a) }
report { p h.at("a") }
report { h[:a] += 1 }

# the index boxed too
k = [:a, 0][0]
report { p h[k] }

# a later step of a dig that lands on an Array
d = {list: [1, 2], n: 1}
report { p d.dig(:list, :a) }

# an Integer index, a Hash, a Struct and a MatchData answer as before
p h[0]
g = pick(1)
p g[:a]
p g["a"]
S = Struct.new(:a)
s = [S.new(7), [1]][0]
p s[:a]
p s["a"]
m = [/(?<x>.)/.match("q"), 5][0]
p m[:x]
p m["x"]

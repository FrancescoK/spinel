# `h[k] op= v` on a String- or Integer-keyed Hash of Integers finds the
# entry once, and `h.fetch(k, default)` on a Hash of Strings probes once
# when the default costs nothing up front. Each still answers as the read,
# the operator and the store (or the lookup and the default) would.

def count_words(words)
  h = Hash.new(0)
  words.each { |w| h[w] += 1 }
  h
end

def count_ints(nums)
  h = Hash.new(0)
  nums.each { |n| h[n] += 1 }
  h
end

words = []
100.times { |i| words << "w#{i % 37}" }
c = count_words(words)
puts c.size
puts c["w0"]
puts c["w36"]

ci = count_ints((0...300).map { |i| i % 41 })
puts ci.size
puts ci[0]
puts ci[40]

# every operator on the same slot
h = Hash.new(5)
h["a"] -= 2
h["a"] *= 7
h["a"] |= 64
h["a"] <<= 1
h["a"] %= 100
puts h["a"]

# the value of the assignment is the new value
k = { 1 => 10 }
x = (k[1] += 5)
puts x
puts k[1]

# a key the hash grows past 16 entries for, one at a time
g = Hash.new(0)
40.times { |i| g["k#{i}"] += i }
puts g.size
puts g["k39"]

# no default: a miss reads nil, and nil + 1 raises before anything is stored
nd = { "a" => 1 }
begin
  nd["b"] += 1
rescue NoMethodError
  puts "nil + 1 raised"
end
puts nd.size

ni = { 1 => 1 }
begin
  ni[2] += 1
rescue NoMethodError
  puts "nil + 1 raised"
end
puts ni.size

# frozen: the read and the operator run, then the store raises
fz = Hash.new(0)
fz["a"] = 1
fz.freeze
begin
  fz["a"] += 1
rescue FrozenError
  puts "frozen"
end
puts fz["a"]

# a right-hand side that changes the hash reads the slot before it runs
def grow(h)
  30.times { |i| h["g#{i}"] = i }
  1
end
gh = Hash.new(0)
gh["a"] = 3
gh["a"] += grow(gh)
puts gh["a"]
puts gh.size

# fetch with a default
ss = { "a" => "x", "b" => "yy" }
puts ss.fetch("a", "").length
puts ss.fetch("z", "").length
dflt = "dd"
puts ss.fetch("z", dflt)
puts ss.fetch("b", dflt)
is = { 1 => "one" }
puts is.fetch(1, "")
puts is.fetch(2, "none")

def fallback
  "called"
end
puts ss.fetch("z", fallback)
puts ss.fetch("a", fallback)

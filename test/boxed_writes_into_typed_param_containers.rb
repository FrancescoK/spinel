# A key or value a method stores through a container parameter is boxed when
# it is another parameter its callers pass different kinds for. Each call's
# argument is checked against the container, which widens where one cannot
# hold it. And an array a builtin returns widens with a parameter that stores
# a foreign element into it, as an array literal does.

def put(h, k, v); h[k] = v; end

# the reproducer: "z" was stored as 0
x = {"a" => 1}
put(x, "b", 2)
put(x, "c", "z")
p x

# two callers with differently typed hashes
a = {"a" => 1}
b = {"a" => "s"}
put(a, "b", 2)
put(b, "c", "z")
put(a, "d", :w)
p a, b

# a boxed key
k = {"a" => 1}
put(k, "b", 2)
put(k, :c, 3)
p k

# handed on through another method's parameters
def via(h, k, v); put(h, k, v); end
c = {"a" => 1}
via(c, "b", 2)
via(c, "c", :sym)
p c

$g = {"a" => 1}
put($g, "x", 1.5)
p $g

class Holder
  attr_reader :h, :arr
  def initialize; @h = {"a" => 1}; @arr = "1 2".split.map(&:to_i); end
  def fill
    put(@h, "b", 2)
    put(@h, "c", nil)
    put(@h, "d", "q")
    seta(@arr, 0, "s")
    self
  end
end

def seta(arr, i, v); arr[i] = v; end
ys = ["a"]
seta(ys, 0, "b")
fs = [1.5]
seta(fs, 0, 2.5)
xs = [1, 2, 3]
seta(xs, 0, 5)
seta(xs, 1, "t")
p ys, fs, xs
hd = Holder.new.fill
p hd.h, hd.arr

class Kept
  def initialize; @arr = [1, 2]; end
  def fill; seta(@arr, 1, 3); p @arr; end
end
Kept.new.fill

def app(arr, v); arr << v; end
zs = [1]
app(zs, 2)
app(zs, "three")
p zs

# the second reproducer: a method's result, not a literal
def poke(arr); arr[0] = "s"; end
poke(["x"])
nums = "1 2".split.map(&:to_i)
poke(nums)
p nums
ts = (1..3).to_a
poke(ts)
p ts
us = [3, 1].sort
poke(us)
p us
p poke([9])

def setv(arr, v); arr[0] = v; end
ia = [1, 2]
setv(ia, 1)
ib = "1 2".split.map(&:to_i)
setv(ib, 2.5)
fa = [1.5]
setv(fa, 3)
p ia, ib, fa

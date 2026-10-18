# A local only Hash.new(default) builds, passed beside an object of another
# class to one parameter, is a Hash there: the parameter holds either.
class Bag
  def initialize = @h = {}
  def [](k) = @h[k] || 0
  def []=(k, v)
    @h[k] = v
  end
end

def bump(t, k)
  t[k] += 1
end

def tag(t, k)
  t[k] += "y"
end

b = Bag.new
bump(b, :a)
c = Hash.new(0)
bump(c, :a)
bump(c, :a)
p b[:a], c
s = Hash.new("")
tag(s, :x)
tag(Bag.new, :x) rescue p $!.class
p s

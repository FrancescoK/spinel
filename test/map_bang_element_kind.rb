# map! whose block answers another kind than a typed Array's elements: the
# Array widens, and the call answers the receiver itself. In value position
# the call was typed as an Array of the block's kind while the receiver had
# widened to a general one, and through a parameter, an ivar or a block
# parameter the Array did not widen at all: either way the C did not build.
a = [1.5, 2.5]
p a.map! { |x| x.to_i }, a
b = [1.5]
p b.map! { 0 }
c = [1, 2]
p c.map! { |x| x.to_s }
d = ["x", "yy"]
p d.collect! { |x| x.size }
e = [:a]
p e.map! { |x| x.to_s }
f = [1, 2]
g = f.map! { |x| x.to_s }
g << 3
p f, g.equal?(f)
def via(arr) = arr.map! { |x| x.to_s }
h = [1, 2]
p via(h), h
def via_stmt(arr)
  arr.map! { |x| x * 1.5 }
  arr
end
p via_stmt([1, 2])
class K
  def initialize; @a = [1, 2]; end
  def run
    @a.map! { |x| x.to_s }
    @a
  end
end
p K.new.run
[[1, 2]].each { |x| x.map! { |y| y.to_s }; p x }
i = [1, 2]
i.map! { |x| x * 2 }
p i

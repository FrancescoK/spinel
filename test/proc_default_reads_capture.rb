# A proc parameter default that reads a captured local, self or an ivar

y = 5
m = ->(x = "v#{y}") { x }
p m.call

m = ->(x = y) { x }
p m.call
p m.call(1)

m = ->(x = y + 1) { x }
p m.call

m = ->(k: y) { k }
p m.call
p m.call(k: 2)

m = proc { |x = y| x }
p m.call

[[1], [2, 3]].each { |x, z = y| p [x, z] }

m = ->(x = y) { x }
y = 7
p m.call

cnt = 0
m = ->(x = (cnt += 1)) { x }
p m.call
p m.call
p cnt

def mk(n)
  s = "s"
  ->(x = n * 2, k: s + "!") { [x, k] }
end
f = mk(4)
p f.call
p f.call(1, k: "z")

def keep(&b) = b
arr = [1, 2]
b = keep { |x = arr.size| x }
p b.call
p b.call(9)

class K
  attr_reader :w
  def initialize; @v = 4; @w = 3; end
  def h; 9; end
  def go
    m = ->(x = @v, z = h) { [x, z] }
    p m.call
    m = ->(k: w, j: self.w + 1) { [k, j] }
    p m.call
    p m.call(k: 0)
  end
end
K.new.go

g = ->(x = [1, 2].map { |i| i + 1 }) { x }
p g.call
g = ->(x = [1, 2].map { |i| i + y }) { x }
p g.call
h = ->(x = Array.new(2) { |j| "s#{j}#{y}" }, k: [3].map { |q| q * y }) { [x, k] }
p h.call

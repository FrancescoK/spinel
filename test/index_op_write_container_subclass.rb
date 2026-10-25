# `x[k] op= v` on a Hash or Array subclass that defines only one of [] and
# []=: the other is the builtin's, and the op-write calls both.
class H < Hash
  def [](k) = super(k) || 10
end
h = H.new
h[:a] += 1
h[:a] -= 3
h[:b] ||= 5
h[:b] &&= 7
p h
p(h[:d] += 2)
[1, 2].each { |i| h[i] += i }
p h

class Counter < Hash
  def [](k) = fetch(k, 0)
end
c = Counter.new
%w[a b a c a b].each { |w| c[w] += 1 }
p c
k = "a"
c[k] += 10
p c["a"]

class Text < Hash
  def [](k) = super(k) || "def"
end
t = Text.new
t[:a] += "x"
t[:a] << "!"
p t

class Doubler < Hash
  def []=(k, v)
    super(k, v * 2)
  end
end
d = Doubler.new
d[:a] = 1
d[:a] += 1
p d

class Strs < Array
  def []=(i, v)
    super(i, v.to_s)
  end
end
s = Strs.new([1, 2])
s[0] += 1
p s

class Tens < Array
  def [](i) = (super(i) || 0) * 10
end
a = Tens.new([1, 2])
a[0] += 1
a[1] -= 1
p a

# the op-write answers the value it assigns, not what []= returns
class Twice < Hash
  def []=(k, v)
    super(k, v * 2)
  end
end
d = Twice.new
d[:a] = 1
p(d[:a] += 1)
p(d[:b] ||= 5)
p(d[:b] &&= 3)
p d

# a variable that holds objects of two such classes, or one and a Hash
class Twice2 < Hash
  def []=(k, v)
    super(k, v * 2)
  end
end
class Plus
  def initialize = @h = {}
  def [](k) = @h[k] || 0
  def []=(k, v)
    @h[k] = v + 100
  end
  def to_s = @h.inspect
end
[Twice.new, Twice2.new, {}].each do |x|
  x[:a] = 1
  x[:a] += 1
  p x
end
[Plus.new, Twice.new(0)].each do |x|
  x[0] += 1
  puts x
end

# the same on a local receiver whose class defines both, and on a module
class Both < Hash
  def [](k) = super(k) || 0
  def []=(k, v)
    super(k, v * 2)
  end
end
b = Both.new
p(b[:a] += 1)
p(b[:z] &&= 3)
p(b[:q] ||= 4)
p b
class Box
  def initialize = (@h = {})
  def [](k) = @h[k]
  def []=(k, v)
    @h[k] = v * 2
    :ret
  end
end
x = Box.new
x[:a] = 1
p(x[:a] += 1)
p(x[:n] ||= 7)
module Reg
  @h = {}
  def self.[](k) = @h[k]
  def self.[]=(k, v)
    @h[k] = v
    :stored
  end
end
p(Reg[:x] ||= 1)
p(Reg[:x] += 1)
i = 0
p(b[i += 1] += 1, i)

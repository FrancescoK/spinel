# `r[k] = v` answers v, whatever the program's `[]=` returns.

class Box
  def initialize = (@h = {})
  def [](*k) = @h[k]
  def []=(*a)
    v = a.pop
    @h[a] = v
    :ret
  end
  def put(k, v) = (self[k] = v)
  def tail_set(k) = self[k, k] = "t#{k}"
end

module Store
  def []=(k, v)
    @log ||= []
    @log << [k, v]
    nil
  end
  def log = @log
end

class Inc
  include Store
end

class Priv
  def initialize = (@x = nil)
  def run = (self[1] = 42)

  private

  def []=(k, v)
    @x = [k, v]
    :p
  end
end

class H < Hash
  def []=(k, v)
    super(k, v * 2)
  end
end

class A < Array
  def []=(i, v)
    super(i, v + 1)
  end
end

b = Box.new
p(b[:a] = 1)
x = (b[:c] = 5)
p x

# each part runs once, in Ruby's order
i = 0
r = (b[i] = (i += 1))
p r, b[0], b[1]
seq = []
p((seq << 1; b)[(seq << 2; :k)] = (seq << 3; 7))
p seq

p(b[:x, :y] = 3.5)
p b.put(:q, nil)
p b.tail_set(9)

s = +"str"
x = (b[:s] = s)
p x.equal?(s)
x << "!"
p b[:s]

c = Inc.new
p(c[:a] = 1)
p c.log
p Priv.new.run

p([1, 2].map { |e| b[e] = e * 10 })
y = if r then b[:z] = :zz end
p y
p(b[:f] = "lit")

h = H.new
p(h[:a] = 1)
p h
w = (h["s"] = 2) + 1
p w
def chain(h) = (h[:c] = h[:d] = 9)
p chain(H.new)

a = A.new([0, 0])
p(a[0] = 1)
p a

# a box that holds either kind
[H.new, Box.new].each { |o| p(o[:k] = 4) }
o = ARGV.empty? ? Box.new : H.new
p(o[:j] = 5)

Pt = Struct.new(:a)
pt = Pt.new(1)
p(pt[:a] = 5)

# a long key list
p(b[1, 2, 3, 4, 5, 6, 7, 8] = 9)

class Coll
  def initialize = @items = {}
  def initialize_copy(_orig) = @items = @items.dup

  def []=(k, v)
    @items[k] = v
  end

  def size = @items.size
end

class Base
  attr_reader :log

  def initialize
    @log = []
  end

  def initialize_copy(orig)
    @log = orig.log.dup
    @log << :copied
  end
end

class Sub < Base
end

class Plain
  attr_reader :arr

  def initialize
    @arr = [1]
  end
end

class Deep
  attr_reader :n

  def initialize(n)
    @n = n
  end

  def dup = Deep.new(@n + 100)
  def clone = Deep.new(@n + 200)
end

x = [Coll.new, 1][0]
y = x.dup
y[:a] = 1
p [x.size, y.size]

z = Coll.new
w = z.dup
w[:b] = 2
p [z.size, w.size]

s = [Sub.new, 1][0]
t = s.dup
p [s.log, t.log]
p [Base.new, "x"][0].clone.log

q = [Plain.new, 1][0]
r = q.dup
r.arr << 2
p [q.arr, r.arr, q.equal?(r)]

f = [Base.new.freeze, 1][0]
g = f.clone
p [g.frozen?, g.log]
h = f.dup
p [h.frozen?, h.log]
k = f.clone(freeze: false)
p [k.frozen?, k.log]

d = [Deep.new(1), 1][0]
p [d.dup.n, d.clone.n]

m = [[1, 2], 1][1]
p m.dup
a = [[1, 2], 1][0]
a2 = a.dup
a2 << 3
p [a, a2]

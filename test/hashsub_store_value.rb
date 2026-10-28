# Hash#store used as a value on a Hash subclass instance answers the
# stored value, as Hash#[]= does. The class's own []= is not called.

class H < Hash; end
h = H.new
p h.store(:z, 4)
v = h.store("k", [1])
v << 2
p h
p [1, 2].map { |i| h.store(i, i * 2) }
p h.class

class G < H; end
g = G.new
p g.store(:a, 1)
p g

class Tens < Hash
  def []=(k, v)
    super(k, v * 10)
  end
end
t = Tens.new
p t.store(:a, 1)
t[:b] = 2
p t

class Twice < Hash
  def store(k, v) = super(k, v * 2)
end
w = Twice.new
p w.store(:z, 4)
p w

class Own < Hash
  def go = store(:q, 5)
  def go2 = self.store(:r, 6)
end
o = Own.new
p o.go
p o.go2
p o

e = H.new
p(e.instance_eval { store(:y, 3) })
e.instance_eval { self.store(:x, 7) }
p e

f = H.new.freeze
begin
  f.store(:x, 1)
rescue FrozenError => ex
  p ex.class
end

# undefined or private: NoMethodError, except on self
class NoStore < Hash; undef_method :store; end
class PrivStore < Hash
  private :store
  def go = store(:q, 2)
end
begin
  p NoStore.new.store(:a, 1)
rescue NoMethodError
  p NoStore
end
begin
  p PrivStore.new.store(:a, 1)
rescue NoMethodError
  p PrivStore
end
ps = PrivStore.new
p ps.go
p ps

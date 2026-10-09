class Cnt
  def initialize(n) = (@n = n)

  def to_int
    junk = []
    200.times { |i| junk << "x#{i}" * 3 }
    @n
  end
end

def fresh(k) = Array.new(k) { |i| "e#{i}" * 2 }
def ints(k) = Array.new(k) { |i| i * 7 }

p fresh(3) * 2
p ints(4) * 3
c3 = Cnt.new(3)
p (ints(2) * c3).sum
p (fresh(2) * c3).size

class Maybe
  def initialize(f)
    @h = {b: 2} if f
  end

  def to_hash = @h
end

class MaybeSub < Maybe; end

h = {a: 1, b: 5}
p h.merge!(Maybe.new(true)) { |_k, x, y| x + y }
begin
  h.merge!(Maybe.new(false)) { |_k, x, y| x + y }
rescue TypeError => e
  p e.message
end
begin
  h.update(MaybeSub.new(false)) { |_k, x, y| x + y }
rescue TypeError => e
  p e.message
end
g = {a: 1}
begin
  g.merge!({c: 3}, Maybe.new(false))
rescue TypeError => e
  p e.message
end
p g

class Either
  def initialize(f) = (@f = f)
  def to_hash = @f ? {e: 1} : nil
end

k = {a: 1}
p k.merge!(Either.new(true))
begin
  k.merge!(Either.new(false))
rescue TypeError => e
  p e.message
end

class Reader
  def initialize(h) = (@h = h)
  def to_hash = {seen: @h.key?(:b)}
end

class Loud
  def to_hash
    puts "to_hash ran"
    {z: 1}
  end
end

u = {a: 1}
p u.update({b: 2}, Reader.new(u))
fz = {a: 1}.freeze
begin
  fz.update({c: 3}, Loud.new)
rescue FrozenError => e
  p e.class
end

class Key
  def initialize(k) = (@k = k)
  def to_hash = {@k => 1}
end

w = {s: 0}
w.update(Key.new(:a1), Key.new(:a2), Key.new(:a3), Key.new(:a4), Key.new(:a5),
         Key.new(:a6), Key.new(:a7), Key.new(:a8), Key.new(:a9), Key.new(:a10))
p w

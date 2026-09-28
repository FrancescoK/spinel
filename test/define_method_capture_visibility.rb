# A define_method block closes over the locals of the body it is written
# in, and the method it defines takes the visibility a def there would.

class A
  x = 5
  name = "alpha"
  list = [1, 2]
  define_method(:sum) { |a| a + x }
  define_method(:label) { "#{name}:#{x}" }
  define_method(:bump) { x += 1 }
  define_method(:push) { |v| list << v; list.size }
  define_method(:each_sum) { list.map { |e| e + x }.sum }
  define_method(:set_in_block) { [3].each { |e| x = e * 10 }; x }
  x = 7
  p x
end
a = A.new
p a.sum(1)
p a.label
p a.bump
p A.new.bump
p a.push(9)
p a.each_sum
p a.set_in_block
p a.sum(1)

module M
  k = 3
  define_method(:triple) { k * 3 }
end
class UsesM
  include M
end
p UsesM.new.triple

class Kw
  base = 100
  define_method(:kw) { |a, w: 1| a + w + base }
end
p Kw.new.kw(1, w: 2)

class Shadow
  x = 1
  define_method(:sh) { |x| x * 2 }
  define_method(:local_only) { y = 5; y + x }
end
p Shadow.new.sh(10)
p Shadow.new.local_only

x = :top
class Other
  x = 42
  define_method(:ox) { x }
end
p Other.new.ox
p x

class Outer
  a = 1
  class Inner
    a = 2
    define_method(:ia) { a }
  end
  define_method(:oa) { a }
end
p Outer.new.oa
p Outer::Inner.new.ia

class Each
  pre = "p"
  %w[a b].each do |n|
    define_method("m_#{n}") { "#{pre}#{n}" }
  end
end
p Each.new.m_b

class Poly
  val = 1
  define_method(:get) { val }
  define_method(:set) { |nv| val = nv }
end
o = Poly.new
p o.get
o.set("s")
p o.get

class Multi
  a, b = 3, 4
  define_method(:ab) { a * b }
  define_method(:swap) { a, b = b, a; [a, b] }
end
p Multi.new.ab
p Multi.new.swap
p Multi.new.swap

class Single
  q = 8
  define_singleton_method(:cq) { q }
end
p Single.cq

t = 3
define_method(:tt) { t * 2 }
p tt

class K1
  private
  define_method(:q) { |w| w }
end
class K2
  define_method(:q) { |w| w }
  private :q
end
class K3
  private define_method(:q) { |w| w }
end
class K4
  protected
  define_method(:q) { |w| w }
  public
  define_method(:r) { |o| o.q(2) }
end
class K5
  private
  define_method(:q) { |w| w }
  public :q
end
class K6
  z = 4
  private
  define_method(:q) { |w| w + z }
  define_method(:k) { |w: 1| w }
  define_method(:r) { q(7) + k }
  define_method(:s) { self.q(8) }
  public :r, :s
end
[K1, K2, K3, K4, K5, K6].each do |k|
  begin
    p k.new.q(1)
  rescue NoMethodError => e
    p e.class
  end
end
p K4.new.r(K4.new)
p K6.new.r
p K6.new.s
begin
  K6.new.k
rescue NoMethodError => e
  p e.class
end

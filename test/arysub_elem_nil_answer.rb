# An element read on an Array or Hash subclass instance that can be nil
# answers its nil to ||, &&, nil? and the other places that test it.

class A < Array; end
class H < Hash; end
a = A.new([1, 2])
p(a[5] || 7)
p a[5].nil?, a[0].nil?
p(a[0] && 3)
p(a[9] && 3)
p a.first, a.last
e = A.new
p(e.first || :none, e.last.nil?, e.max.nil?, e.min || 0)
p a.at(4).nil?, a.fetch(9, nil).nil?
x = a[1] + 1
p x
z = a[7]
p z
p(z.nil? ? :nil : z)
h = H.new
h[:a] = 1
p(h[:b] || 5, h[:a] || 6, h[:b].nil?)
p a.index(2), a.index(9).nil?
p a.pop, A.new.pop.nil?

class AW < Array
  def []=(i, v)
    super(i, v * 10)
  end
end
a = AW.new([1])
a[3] ||= 7
p a
b = AW.new([2])
b[0] ||= 9
p b

h = H.new(0)
p h[:x] + 1
h2 = H.new
p(h2[:y] || -1)

# a super into Array's own method, and a String subclass
class SA < Array
  def [](i) = (super(i) || 0) + 1
  def first
    v = super
    v.nil? ? -1 : v
  end
end
sa = SA.new([1, 2])
p sa[0], sa[9], sa.first, SA.new.first
class B < Array
  def last = super || 0
end
p B.new.last, B.new([4]).last
class S < String; end
s = S.new("ab")
p(s.index("z") || 5, s.rindex("q") || 6, s.byteindex("x") || 7, s.index("b") + 1, s.getbyte(9) || 1)

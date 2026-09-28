class D
  def initialize(*r, c) = (@r = r; @c = c)
  def show = "D #{@r.inspect} #{@c.inspect}"
end
class G
  def initialize(a, *r, c) = (@a = a; @r = r; @c = c)
  def show = "G #{@a} #{@r.inspect} #{@c}"
end
class H2
  def initialize(a = 1, *r, c) = (@a = a; @r = r; @c = c)
  def show = "H #{@a} #{@r.inspect} #{@c}"
end
class K
  def initialize(*r) = (@r = r)
  def show = "K #{@r.inspect}"
end
class I
  def initialize(a = 1, b, **kw) = (@a = a; @b = b; @kw = kw)
  def show = "I #{@a} #{@b} #{@kw.inspect}"
end

L = [D, G, H2, K, I]
puts L[0].new(10).show
puts L[0].new(10, 20).show
puts L[0].new(10, 20, 30).show
puts L[1].new(10, 20).show
puts L[1].new(10, 20, 30, 40).show
puts L[2].new(10).show
puts L[2].new(10, 20).show
puts L[2].new(10, 20, 30).show
puts L[3].new.show
puts L[3].new(10, 20).show
puts L[4].new(10).show
puts L[4].new(10, 20).show

M = { d: D, h: H2 }
puts M[:d].new(7, 8, 9).show
puts M[:h].new(7).show
k = ARGV.empty? ? D : G
puts k.new(1, 2).show

# A class's own dup, clone or freeze is called, with or without arguments,
# in place of the built-in copy or identity: Nokogiri's Node#dup is a deep
# copy (#5450). A class that defines none keeps the built-in shallow dup.
class F
  def initialize(s); @s = s; end
  def s; @s; end
  def dup(level = 1); F.new(@s + "!" * level); end
end
p F.new("a").dup.s
p F.new("a").dup(2).s

class G
  attr_accessor :v
  def initialize(v) = @v = v
  def dup = self.class.new(v.map { |x| x * 10 })
  def clone = G.new([:cloned])
  def freeze = (@frozen_by_me = true; self)
  def frozen_by_me = @frozen_by_me
end
g = G.new([1, 2])
d = g.dup
d.v << 3
p g.v, d.v, d.equal?(g)
p g.clone.v
p g.freeze.frozen_by_me

class H
  def initialize = @a = [1]
  attr_reader :a
end
h = H.new
h2 = h.dup
p h2.equal?(h), h2.a.equal?(h.a)

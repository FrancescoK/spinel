# A class's own dup or clone is typed by what its body answers, not as the
# receiver the built-in copy would be: `def dup = self.class.new(...)` answers
# the caller's subclass boxed (#5461, Nokogiri's DocumentFragment#dup).
class F
  def initialize(s); @s = s; end
  def s; @s; end
  def dup; self.class.new(@s + "!"); end
end
class G < F; end
p G.new("g").dup.s
p F.new("f").dup.s
x = G.new("h").dup
p x.class, x.s
class K
  def initialize(n) = @n = n
  attr_reader :n
  def clone(freeze: nil) = K.new(@n + 1)
end
p K.new(1).clone.n

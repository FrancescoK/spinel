# `...` forwarded into a Struct or Data class's new, from an initialize or a
# method: the class has no initialize of its own to read a shape from, and
# the call was refused ("unsupported expression: ForwardingArgumentsNode").
# Its new takes positional and keyword arguments, and both are forwarded.

Pair = Struct.new(:a, :b)
class Pt < Struct.new(:x, :y)
  def sum = x + y
end
D = Data.define(:a, :b)
module M
  Rec = Struct.new(:v)
end
class W
  def initialize(...)
    @p = Pair.new(...)
  end
  attr_reader :p
end
class WP
  def initialize(...) = @p = Pt.new(...)
  attr_reader :p
end
class WD
  def initialize(...) = @p = D.new(...)
  attr_reader :p
end
class WM
  def initialize(...) = @p = M::Rec.new(...)
  attr_reader :p
end
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
t { W.new(1, 2).p }
t { W.new(1).p }
t { W.new(1, 2) { 3 }.p }
t { WP.new(3, 4).p.sum }
t { WD.new(1, 2).p }
t { WD.new(a: 1, b: 2).p }
t { WD.new(1).p }
t { WM.new(7).p }
def mk(...) = Pair.new(...)
t { mk(5, 6) }
P2 = Struct.new(:a, :b, keyword_init: true)
class WK
  def initialize(...) = @p = P2.new(...)
  attr_reader :p
end
t { WK.new(a: 1, b: 2).p }

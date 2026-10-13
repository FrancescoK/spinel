# spinel: gc-stress
# `k.new(...)` on a class read out of an Array dispatches over the classes
# it can be, and each arm fills the parameters the call leaves out: an
# empty **kwrest is a new Hash and a default may build a new value, each
# made in the constructor's argument list. The constructor allocates the
# object first, which freed them under SPINEL_GC_STRESS=2.
class I
  def initialize(a = 1, b, **kw) = (@a = a; @b = b; @kw = kw)
  def show = "I #{@a} #{@b} #{@kw.inspect}"
end
class P
  def initialize(s, t = "#{s}!", **kw) = (@s = s; @t = t; @kw = kw)
  def show = "P #{@s} #{@t} #{@kw.inspect}"
end
L = [I, P]
x = 5
puts L[0].new(10).show
puts L[0].new(10, 20).show
puts L[1].new("v#{x}").show
puts L[1].new("w#{x}", "u").show

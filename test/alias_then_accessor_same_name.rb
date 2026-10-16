# An accessor declared after an alias of the same name replaces the alias,
# as a later definition does; one declared before it is replaced by the
# alias. Readers and writers alike, through `alias` and `alias_method`.
class V
  def initialize(n) = (@n = n)
  def val = @n
end
class D
  attr_reader :x
  alias y x
  attr_reader :y
  alias_method :z, :x
  attr_accessor :z
  attr_reader :w
  alias w x
  attr_writer :a
  alias b= a=
  attr_writer :b
  def initialize = (@x = V.new(1); @y = V.new(2); @z = V.new(3); @w = V.new(4))
  def ab = [@a, @b]
end
d = D.new
p d.y.val, d.z.val, d.w.val
d.z = V.new(5)
d.b = 6
p d.z.val, d.ab, D.instance_methods(false).sort

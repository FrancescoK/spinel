# An attr call splatting a constant Array literal of names declares those
# names, as `attr_accessor(:a, :b)` would; it declared nothing before.
class C
  FLAGS = %i[a b]
  NAMES = %w[x y]
  attr_accessor(*FLAGS)
  attr_reader :z, *NAMES
  attr_writer(*NAMES)
  def initialize = (@z = 0; @x = 1; @y = 2)
  def flags = FLAGS.map(&:to_s).join(",")
end
c = C.new
c.a = 1
c.b = 2
c.x = 10
p [c.a, c.b, c.x, c.y, c.z, c.flags]

module M
  KEYS = [:k]
  attr_accessor(*KEYS)
end

class D
  include M
end
d = D.new
d.k = 3
p d.k

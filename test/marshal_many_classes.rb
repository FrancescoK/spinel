# Marshal over many classes: a load finds each class by its name, a
# namespaced one by its full name, and each class's ivars round-trip with
# their kinds, a nil, an unset one and a nested object among them.
module Zoo
  class Panda
    def initialize(n) = (@name = n; @age = n.size)
    attr_reader :name, :age
  end
end

class Zeta
  def initialize(x) = (@x = x; @tags = [:a, :b])
  attr_reader :x, :tags
end

class Alpha
  def initialize(f) = (@f = f; @h = { "k" => f * 2 })
  attr_reader :f, :h
end

class Mid
  def initialize(o) = (@o = o; @n = nil)
  attr_reader :o, :n
end

class Late
  def initialize = @a = 1
  def set_b = @b = "b"
  attr_reader :a
end

class Base
  def initialize(v) = @v = v
  attr_reader :v
end

class Sub < Base
  def initialize(v, w) = (super(v); @w = w)
  attr_reader :w
end

def hex(o) = Marshal.dump(o).unpack1("H*")

objs = [Zoo::Panda.new("mei"), Zeta.new(3), Alpha.new(1.5), Mid.new(Zeta.new(4)), Late.new, Sub.new(1, "two")]
objs.each { |o| puts hex(o) }
late = Late.new
late.set_b
puts hex(late)

pa = Marshal.load(Marshal.dump(objs[0]))
p [pa.class, pa.name, pa.age]
z = Marshal.load(Marshal.dump(objs[1]))
p [z.class, z.x, z.tags]
al = Marshal.load(Marshal.dump(objs[2]))
p [al.class, al.f, al.h]
m = Marshal.load(Marshal.dump(objs[3]))
p [m.class, m.o.class, m.o.x, m.n]
l = Marshal.load(Marshal.dump(late))
p [l.class, l.a, l.instance_variables]
s = Marshal.load(Marshal.dump(objs[5]))
p [s.class, s.v, s.w]
begin
  Marshal.load("\x04\bo:\vNoSuch\x00")
rescue ArgumentError => e
  p e.class
end

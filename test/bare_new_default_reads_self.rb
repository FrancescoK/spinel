class B
  attr_reader :size, :cells
  def initialize(size, cells = make(size))
    @size = size
    @cells = cells
  end
  def self.from(n) = new(n)
  def self.with(n) = new(n, [:given])
  def self.splat(*a) = new(*a)
  def make(n) = Array.new(n, self.class.name)
end
p B.from(2).cells, B.with(2).cells, B.splat(1).cells, B.splat(1, [0]).cells
class P
  attr_reader :v
  def initialize(v = tag) = (@v = v)
  def tag = "#{self.class}!"
  def self.build = new
  def self.build_blk = new { 1 }
end
p P.build.v, P.build_blk.v
class V
  attr_reader :x, :y
  def initialize(x, y = twice(x)) = (@x = x; @y = y)
  def twice(n) = n * 2
  def self.at(n) = new(n)
end
p V.at(3).y
class W
  attr_reader :k
  def initialize(k: kdef) = (@k = k)
  def kdef = :dk
  def self.mk = new
  def self.mk2 = new(k: 1)
end
p W.mk.k, W.mk2.k
class BB
  attr_reader :cells
  def initialize(n, cells = make(n)) = (@cells = cells)
  def self.from(n) = new(n)
  def make(n) = Array.new(n, self.class.name)
end
class CC < BB
  def initialize(n, cells = [:c, n]) = (@cells = cells)
end
class DD < BB
  def make(n) = [:d] * n
end
p BB.from(1).cells, CC.from(2).cells, DD.from(2).cells, DD.from(1).class

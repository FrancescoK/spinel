class A
  def initialize(a = "x", b) = (@a = a; @b = b)
  def show = "#{@a.inspect} #{@b.inspect}"
end
KS = [A].freeze
puts A.new("y", 2).show
puts KS[0].new(3).show

class B
  def initialize(a = 1, b = 2, c) = (@a = a; @b = b; @c = c)
  def show = "B #{@a.inspect} #{@b.inspect} #{@c.inspect}"
end
class C
  def initialize(a, b = 2, c) = (@a = a; @b = b; @c = c)
  def show = "C #{@a.inspect} #{@b.inspect} #{@c.inspect}"
end
class P
  def initialize(a, b) = (@a = a; @b = b)
  def show = "P #{@a.inspect} #{@b.inspect}"
end

ARR = [A, B, C, P]
puts ARR[1].new(10).show
puts ARR[1].new(10, 20).show
puts ARR[1].new(10, 20, 30).show
puts ARR[2].new(10, 20).show
puts ARR[3].new(10, 20).show

H = { a: A, b: B, c: C, p: P }
puts H[:a].new(7).show
puts H[:b].new(7, 8).show
puts H[:c].new(7, 8, 9).show
puts H[:p].new(7, 8).show

flag = ARGV.empty?
puts (flag ? A : P).new(5).show
puts (flag ? B : C).new(5, 6).show
k = flag ? A : B
puts k.new(4).show
k = flag ? P : A
puts k.new(4, 5).show

class F
  def initialize(a = seed, b) = (@a = a; @b = b)
  def seed = 42
  def show = "F #{@a} #{@b}"
end
puts F.new(8).show
puts F.new(1, 8).show

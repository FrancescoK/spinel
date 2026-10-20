# spinel: gc-stress
# A target's receiver or key read from an instance or global variable is read
# before any store, even where an earlier target's writer changes the variable
# (CRuby evaluates every receiver and key before it assigns), and the same
# where the right side changes the variable or the local a key reads.
class C
  def initialize; @i = 0; @a = [0, 0, 0]; end
  def x=(v); @i = v; end
  def go
    self.x, @a[@i] = 2, 9
    p @a
    @i = 0
    (self.x, y), @a[@i] = [1, 5], 7
    p @a
  end
end
C.new.go
$i = 0
A = [0, 0, 0]
class D; def x=(v); $i = v; end; end
d = D.new
d.x, A[$i] = 2, 9
p A

class E
  def initialize; @i = 0; @a = [0, 0, 0]; end
  def bump; @i = 2; 5; end
  def x=(v); @i = v; end
  def go
    @a[@i], y = bump, 1
    p @a
    @i = 0; @a = [0, 0, 0]
    v = (self.x, @a[@i] = 2, 9)
    p [v, @a]
    @i = 0; @a = [0, 0, 0]
    v = (@a[@i], y = bump, 1)
    p [v, @a]
  end
end
E.new.go
a = [0, 0, 0]; i = 0
a[i], y = (i = 2; 5), 1
p a

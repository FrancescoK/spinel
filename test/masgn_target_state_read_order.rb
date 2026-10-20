# spinel: gc-stress
# A target's receiver or key read from an instance or global variable is read
# before any store, even where an earlier target's writer changes the variable
# (CRuby evaluates every receiver and key before it assigns).
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

class C
  def initialize
    @w = {"a" => 1}
    @s = {"a" => "x"}
    @k = {"a" => 1}
  end
  def go
    @w.update("e" => 1.5)
    r = @s.merge!("f" => 2)
    @k.update(b: 2)
    p @w, r, @s, @k
  end
  def go_var
    x = {"z" => 2.5}
    @w.update(x)
    p @w
  end
end
C.new.go
C.new.go_var
class D
  @@h = {"a" => 1}
  def self.go
    @@h.update("b" => :sym)
    p @@h
  end
end
D.go
$g = {1 => 2}
$g.update(3 => :four)
p $g

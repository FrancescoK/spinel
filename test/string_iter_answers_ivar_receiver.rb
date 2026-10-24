# A String iterator with a block (each_char, each_byte, ...) answers its
# receiver. On an ivar, a class variable or a global, which the block can
# rebind, the receiver is read as a copy of its bytes, and that copy was
# the answer: `[@s.each_char { }]` stored a String that was not @s.
class A
  def go
    @s = +"new"
    r = [@s.each_char { }]
    r[0] << "!"
    p @s
    x = @s.each_byte { |b| @s = +"other" if b == 0 }
    p x.equal?(@s)
    @s.each_char { |ch| }
    p @s
  end
end
A.new.go
$g = +"gg"
y = $g.each_char { $g = +"h" }
y << "!"
p y, $g

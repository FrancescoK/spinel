# Under --share-strings (#6765): A tap block that assigns the ivar the chain is over, then a bang, as a boxed ||
# operand and as an arm.
# a tap block reassigning the ivar, then a bang, as an || operand and an arm
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.tap { @s = +"zz" }.upcase! || v
  def n(v)
    x = v ? @s.tap { @s = +"yy" }.upcase! : 1
    x
  end
  def s = @s
end
a = App.new(+"abc")
p a.m(1), a.s
a = App.new(+"abc")
p a.n(true), a.s

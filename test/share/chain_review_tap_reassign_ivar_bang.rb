# Under --share-strings (#6765), a chain of calls answering their receiver that
# a boxed || or && takes answers what CRuby 4.0 does; a block that assigns
# the variable the chain is over leaves the chain on the String it started from.
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

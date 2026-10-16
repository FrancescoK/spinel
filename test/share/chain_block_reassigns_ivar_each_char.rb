# Under --share-strings (#6765): An each_char block that assigns the ivar the chain is over, then a bang.
# each_char with a block that reassigns the slot, then a bang
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.each_char { |c| @s = +"qq" if c == "a" }.upcase! || v
  def s = @s
end
a = App.new(+"abc")
p a.m(1), a.s

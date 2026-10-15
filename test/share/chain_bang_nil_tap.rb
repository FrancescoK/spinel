# Under --share-strings (#6765): A bang that answers nil, then a tap given a block that reads its parameter
# (nil), as a boxed || operand.
# a bang answering nil, then tap: nil.tap answers nil
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.upcase!.tap { } || v
  def n(v) = @s.upcase!.tap { |z| p z }.itself || v
end
p App.new(+"ABC").m(1)
p App.new(+"ABC").n(2)
b = +"abc"
x = App.new(b).n(2)
p [x, x.equal?(b)]

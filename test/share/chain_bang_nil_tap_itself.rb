# Under --share-strings (#6765): A bang that answers nil, an empty tap, then itself, as a boxed || operand.
# minimal: a bang answering nil, an empty tap, then itself
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.upcase!.tap { }.itself || v
end
p App.new(+"ABC").m(1)

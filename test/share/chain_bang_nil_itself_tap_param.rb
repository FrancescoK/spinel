# Under --share-strings (#6765): A bang that answers nil, itself, then a tap whose block reads its parameter, as a
# boxed || operand: itself on nil is nil, no NoMethodError.
# minimal: a bang answering nil, itself, a tap whose block reads its parameter
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.strip!.itself.tap { |z| p z } || v
end
p App.new(+"abc").m(1)

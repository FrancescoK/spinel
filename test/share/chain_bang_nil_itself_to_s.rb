# Under --share-strings (#6765): A nil a bang answered goes through itself, and through an empty tap, to a to_s
# as "", as a boxed || operand.
# a nil bang, itself, then to_s
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.upcase!.itself.to_s || v
  def n(v) = @s.upcase!.tap { }.to_s || v
end
p App.new(+"ABC").m(1)
p App.new(+"ABC").n(1)

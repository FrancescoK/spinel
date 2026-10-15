# Under --share-strings (#6765): A bang that answers nil, an empty tap and a to_s or itself, as a boxed || operand:
# tap on nil is nil's own, it answers nil.
# a bang answering nil, then an empty tap, then to_s
class App
  def initialize(s) = (@s = s)
  def n(v) = @s.upcase!.tap { }.to_s || v
  def o(v) = @s.upcase!.tap { }.itself || v
end
p App.new(+"ABC").o(2)
p App.new(+"ABC").n(2)

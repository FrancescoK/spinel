# Under --share-strings (#6765): A bang that answers nil, then to_s, as a boxed || operand answers "" (the to_s of
# nil), a new String, not the slot's: the chain is no longer the slot's String
# once a link below the to_s can answer nil.
# minimal: a bang answering nil, then to_s, as a || operand of a method tail
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.upcase!.to_s || v
end
p App.new(+"ABC").m(1)

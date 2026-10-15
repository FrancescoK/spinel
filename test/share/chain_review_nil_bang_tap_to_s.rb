# Under --share-strings (#6765), a chain of calls answering their receiver that
# a boxed || or && takes (chain_review: h11_nil_bang_tap_to_s) answers what CRuby 4.0 does.
# A nil a bang answered stays nil through tap and itself, and a to_s makes
# "" of it; a block that assigns the variable the chain is over leaves the
# chain on the String it started from.
# a bang answering nil, then an empty tap, then to_s
class App
  def initialize(s) = (@s = s)
  def n(v) = @s.upcase!.tap { }.to_s || v
  def o(v) = @s.upcase!.tap { }.itself || v
end
p App.new(+"ABC").o(2)
p App.new(+"ABC").n(2)

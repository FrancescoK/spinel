# Under --share-strings (#6765), a chain of calls answering their receiver that
# a boxed || or && takes (chain_review: k02_min_nil_tap_empty) answers what CRuby 4.0 does.
# A nil a bang answered stays nil through tap and itself, and a to_s makes
# "" of it; a block that assigns the variable the chain is over leaves the
# chain on the String it started from.
# minimal: a bang answering nil, an empty tap, then itself
class App
  def initialize(s) = (@s = s)
  def m(v) = @s.upcase!.tap { }.itself || v
end
p App.new(+"ABC").m(1)
